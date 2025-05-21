extends Node
class_name GDInk

# GDInk - A Godot module for interpreting Ink scripts
# This module provides integration between Godot 4.x and Ink narrative scripting language

# Signals
signal story_continued(text, tags)
signal choices_available(choices)
signal variable_changed(variable_name, new_value)
signal story_ended
signal error_encountered(message)

# Constants
const INK_INCLUDE_PATTERN = "INCLUDE "
const INK_EXTERNAL_PATTERN = "EXTERNAL "

# Properties
var _story = null
var _variables = {}
var _choices = []
var _current_tags = []
var _story_json = ""
var _ink_filename = ""
var _auto_continue = false

# Preloaded resources
var _json_parser = JSONParseResult.new()

# Class initialization
func _init():
    set_process(false)

# Load and parse an Ink story from JSON
func load_story(json_file_path):
    var file = FileAccess.open(json_file_path, FileAccess.READ)
    if file:
        _ink_filename = json_file_path
        _story_json = file.get_as_text()
        file.close()
        
        # Parse JSON
        var json = JSON.new()
        var error = json.parse(_story_json)
        if error == OK:
            _story = json.get_data()
            _initialize_story()
            return true
        else:
            emit_signal("error_encountered", "Failed to parse JSON: " + str(error))
            return false
    else:
        emit_signal("error_encountered", "Failed to open file: " + json_file_path)
        return false

# Initialize story internals after loading JSON
func _initialize_story():
    # Set up internal story state
    _variables = {}
    _choices = []
    _current_tags = []
    
    # Extract global variables if present
    if _story.has("globalVariables"):
        for var_name in _story["globalVariables"]:
            _variables[var_name] = _story["globalVariables"][var_name]
    
    # Notify that story is ready
    set_process(true)
    emit_signal("story_continued", "", [])

# Continue the story
func continue_story():
    if not _story:
        emit_signal("error_encountered", "No story loaded")
        return false
    
    # Check if we're at the end
    if is_story_ended():
        emit_signal("story_ended")
        return false
    
    # Handle current passage
    var current_passage = _get_current_passage()
    if current_passage:
        var text = current_passage.get("text", "")
        _current_tags = current_passage.get("tags", [])
        
        # Process any variable changes
        _process_variable_changes(current_passage)
        
        # Move story forward
        _story["currentNodeIndex"] = current_passage.get("nextNodeIndex", -1)
        
        # Get available choices after continuing
        _update_choices()
        
        # Emit signals
        emit_signal("story_continued", text, _current_tags)
        if _choices.size() > 0:
            emit_signal("choices_available", _choices)
        
        # Check if story ended after this continuation
        if is_story_ended():
            emit_signal("story_ended")
        
        return true
    
    return false

# Make a choice from available options
func choose(choice_index):
    if not _story:
        emit_signal("error_encountered", "No story loaded")
        return false
    
    if choice_index < 0 or choice_index >= _choices.size():
        emit_signal("error_encountered", "Invalid choice index: " + str(choice_index))
        return false
    
    var choice = _choices[choice_index]
    if choice and choice.has("nodeIndex"):
        _story["currentNodeIndex"] = choice["nodeIndex"]
        _choices = []
        
        # Auto-continue if enabled
        if _auto_continue:
            continue_story()
        return true
    
    return false

# Get available choices
func get_choices():
    return _choices

# Check if story has ended
func is_story_ended():
    if not _story:
        return true
    
    return _story.get("currentNodeIndex", -1) == -1

# Get a variable value
func get_variable(variable_name):
    return _variables.get(variable_name, null)

# Set a variable value
func set_variable(variable_name, value):
    if variable_name in _variables:
        _variables[variable_name] = value
        emit_signal("variable_changed", variable_name, value)
        return true
    
    return false

# Get all current tags
func get_current_tags():
    return _current_tags

# Enable or disable auto-continue after choices
func set_auto_continue(enabled):
    _auto_continue = enabled

# Save current story state (returns a Dictionary that can be saved)
func save_state():
    if not _story:
        emit_signal("error_encountered", "No story loaded")
        return null
    
    return {
        "currentNodeIndex": _story.get("currentNodeIndex", -1),
        "variables": _variables.duplicate(),
        "filename": _ink_filename
    }

# Load a previously saved story state
func load_state(state_dict):
    if not state_dict or not _story:
        emit_signal("error_encountered", "Invalid state or no story loaded")
        return false
    
    # Verify this is the same story
    if state_dict.get("filename", "") != _ink_filename:
        emit_signal("error_encountered", "State is for a different story")
        return false
    
    # Restore state
    _story["currentNodeIndex"] = state_dict.get("currentNodeIndex", -1)
    _variables = state_dict.get("variables", {}).duplicate()
    
    # Update choices based on new state
    _update_choices()
    
    return true

# Internal: Get current passage data
func _get_current_passage():
    var current_index = _story.get("currentNodeIndex", -1)
    if current_index == -1:
        return null
    
    var passages = _story.get("passages", [])
    if current_index >= 0 and current_index < passages.size():
        return passages[current_index]
    
    return null

# Internal: Update available choices
func _update_choices():
    _choices = []
    
    var current_passage = _get_current_passage()
    if current_passage and current_passage.has("choices"):
        _choices = current_passage["choices"].duplicate()

# Internal: Process any variable changes from current passage
func _process_variable_changes(passage):
    if passage and passage.has("variableChanges"):
        for var_change in passage["variableChanges"]:
            var var_name = var_change.get("variableName", "")
            var new_value = var_change.get("newValue", null)
            
            if var_name and var_name in _variables:
                _variables[var_name] = new_value
                emit_signal("variable_changed", var_name, new_value)

# Compiler helper for converting .ink files to JSON
class InkCompiler:
    var _temp_dir = "res://addons/gdink/temp/"
    var _ink_json_compiler_path = ""
    
    func _init(ink_compiler_path = ""):
        _ink_json_compiler_path = ink_compiler_path
    
    # Set the path to the Ink compiler
    func set_compiler_path(path):
        _ink_json_compiler_path = path
    
    # Compile an Ink file to JSON
    func compile_ink_to_json(ink_file_path, output_path = ""):
        if _ink_json_compiler_path.is_empty():
            return ERR_UNCONFIGURED
        
        if ink_file_path.is_empty():
            return ERR_INVALID_PARAMETER
        
        if output_path.is_empty():
            output_path = ink_file_path.get_basename() + ".json"
        
        # Create command to run the compiler
        var args = [ink_file_path, "-o", output_path]
        var output = []
        
        var exit_code = OS.execute(_ink_json_compiler_path, args, output, true)
        
        if exit_code != 0:
            return ERR_COMPILATION_FAILED
        
        return OK