extends Node
class_name InkParser

# InkParser - A parser for Ink script files in Godot
# This helps convert .ink files into a format usable by the GDInk module

# Constants
const KNOT_PATTERN = "=== "
const STITCH_PATTERN = "= "
const CHOICE_PATTERN = "* "
const GATHER_PATTERN = "-"
const DIVERT_PATTERN = "->"
const TAG_PATTERN = "#"
const COMMENT_PATTERN = "//"
const VAR_DECLARATION_PATTERN = "VAR "
const LOGIC_PATTERN = "{"

# Signals
signal parsing_started
signal parsing_completed
signal parsing_failed(error_message)

# Properties
var _parsed_story = {}
var _current_knot = ""
var _current_stitch = ""
var _current_path = []
var _variables = {}
var _includes = []

# Parse an Ink file
func parse_ink_file(file_path):
    var file = FileAccess.open(file_path, FileAccess.READ)
    if file:
        var content = file.get_as_text()
        file.close()
        return parse_ink_content(content)
    else:
        emit_signal("parsing_failed", "Could not open file: " + file_path)
        return null

# Parse Ink content directly
func parse_ink_content(ink_content):
    emit_signal("parsing_started")
    
    # Initialize parsing state
    _parsed_story = {
        "passages": [],
        "globalVariables": {},
        "currentNodeIndex": 0
    }
    _current_knot = ""
    _current_stitch = ""
    _current_path = []
    _variables = {}
    _includes = []
    
    # Split content into lines and process
    var lines = ink_content.split("\n")
    var node_index = 0
    var current_passage = null
    
    for i in range(lines.size()):
        var line = lines[i].strip_edges()
        
        # Skip empty lines and comments
        if line.is_empty() or line.begins_with(COMMENT_PATTERN):
            continue
        
        # Handle includes
        if line.begins_with(GDInk.INK_INCLUDE_PATTERN):
            var include_file = line.substr(GDInk.INK_INCLUDE_PATTERN.length()).strip_edges()
            _includes.append(include_file)
            continue
        
        # Handle external function declarations
        if line.begins_with(GDInk.INK_EXTERNAL_PATTERN):
            # External functions would be processed here
            continue
        
        # Handle variable declarations
        if line.begins_with(VAR_DECLARATION_PATTERN):
            _parse_variable_declaration(line)
            continue
        
        # Handle knots (major sections)
        if line.begins_with(KNOT_PATTERN):
            _current_knot = _parse_header(line, KNOT_PATTERN)
            _current_stitch = ""
            _current_path = [_current_knot]
            
            # Create a new passage for this knot
            current_passage = _create_new_passage()
            current_passage["text"] = ""
            current_passage["nodeIndex"] = node_index
            node_index += 1
            _parsed_story["passages"].append(current_passage)
            continue
        
        # Handle stitches (sub-sections)
        if line.begins_with(STITCH_PATTERN):
            _current_stitch = _parse_header(line, STITCH_PATTERN)
            _current_path = [_current_knot, _current_stitch]
            
            # Create a new passage for this stitch
            current_passage = _create_new_passage()
            current_passage["text"] = ""
            current_passage["nodeIndex"] = node_index
            node_index += 1
            _parsed_story["passages"].append(current_passage)
            continue
        
        # Handle choices
        if line.begins_with(CHOICE_PATTERN):
            var choice_data = _parse_choice(line)
            
            # Add the choice to the current passage
            if current_passage:
                if not current_passage.has("choices"):
                    current_passage["choices"] = []
                
                # Create a new passage for the choice content
                var choice_passage = _create_new_passage()
                choice_passage["nodeIndex"] = node_index
                node_index += 1
                _parsed_story["passages"].append(choice_passage)
                
                # Add this choice to the current passage
                current_passage["choices"].append({
                    "text": choice_data["text"],
                    "nodeIndex": choice_passage["nodeIndex"]
                })
                
                # Move to the choice passage
                current_passage = choice_passage
            continue
        
        # Handle diverts
        if DIVERT_PATTERN in line:
            var divert_data = _parse_divert(line)
            
            if current_passage:
                # Set the next node based on the divert
                var target_path = divert_data["target"]
                current_passage["nextNodeIndex"] = _find_passage_index_by_path(target_path)
            continue
        
        # Handle regular text content
        if current_passage:
            # Check for tags
            var text_line = line
            var tags = []
            
            if TAG_PATTERN in line:
                var tag_parts = line.split(TAG_PATTERN)
                text_line = tag_parts[0].strip_edges()
                
                # Extract tags
                for i in range(1, tag_parts.size()):
                    tags.append(tag_parts[i].strip_edges())
            
            # Add text to current passage
            if not text_line.is_empty():
                if not current_passage["text"].is_empty():
                    current_passage["text"] += "\n"
                current_passage["text"] += text_line
            
            # Add tags if any
            if tags.size() > 0:
                if not current_passage.has("tags"):
                    current_passage["tags"] = []
                current_passage["tags"].append_array(tags)
    
    # Process the variables
    _parsed_story["globalVariables"] = _variables
    
    emit_signal("parsing_completed")
    return _parsed_story

# Create a new passage object
func _create_new_passage():
    return {
        "text": "",
        "nextNodeIndex": -1,
        "nodeIndex": -1
    }

# Parse a header line (knot or stitch)
func _parse_header(line, pattern):
    var header = line.substr(pattern.length()).strip_edges()
    if "(" in header:  # Handle parameters
        header = header.split("(")[0].strip_edges()
    return header

# Parse a variable declaration
func _parse_variable_declaration(line):
    var var_line = line.substr(VAR_DECLARATION_PATTERN.length()).strip_edges()
    var parts = var_line.split("=")
    
    if parts.size() >= 2:
        var var_name = parts[0].strip_edges()
        var var_value = parts[1].strip_edges()
        
        # Convert value to appropriate type
        if var_value == "true":
            _variables[var_name] = true
        elif var_value == "false":
            _variables[var_name] = false
        elif var_value.is_valid_int():
            _variables[var_name] = int(var_value)
        elif var_value.is_valid_float():
            _variables[var_name] = float(var_value)
        else:
            # Remove any quotes for strings
            if var_value.begins_with("\"") and var_value.ends_with("\""):
                var_value = var_value.substr(1, var_value.length() - 2)
            _variables[var_name] = var_value

# Parse a choice line
func _parse_choice(line):
    var choice_text = line.substr(CHOICE_PATTERN.length()).strip_edges()
    var has_condition = false
    var condition = ""
    
    # Check for conditional choices
    if choice_text.begins_with("{") and "}" in choice_text:
        var condition_end = choice_text.find("}")
        condition = choice_text.substr(1, condition_end - 1).strip_edges()
        choice_text = choice_text.substr(condition_end + 1).strip_edges()
        has_condition = true
    
    # Check for choice with divert
    var target_path = ""
    if DIVERT_PATTERN in choice_text:
        var parts = choice_text.split(DIVERT_PATTERN)
        choice_text = parts[0].strip_edges()
        if parts.size() > 1:
            target_path = parts[1].strip_edges()
    
    return {
        "text": choice_text,
        "has_condition": has_condition,
        "condition": condition,
        "has_divert": not target_path.is_empty(),
        "target": target_path
    }

# Parse a divert line
func _parse_divert(line):
    var divert_parts = line.split(DIVERT_PATTERN)
    var text = divert_parts[0].strip_edges()
    var target = ""
    
    if divert_parts.size() > 1:
        target = divert_parts[1].strip_edges()
    
    return {
        "text": text,
        "target": target
    }

# Find a passage index by its path
func _find_passage_index_by_path(path):
    # This is a simplified implementation
    # In a real implementation, you would need to handle relative paths,
    # path components, etc.
    
    # For now, just return -1 to indicate end of story
    # This would need to be expanded considerably
    return -1

# Get the current story structure
func get_parsed_story():
    return _parsed_story

# Get the list of includes
func get_includes():
    return _includes

# Get the parsed variables
func get_variables():
    return _variables