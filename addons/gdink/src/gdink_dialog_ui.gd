extends Control
class_name GDInkDialogUI

# GDInkDialogUI - A simple dialog UI component for GDInk
# This provides a basic UI for displaying Ink stories

# Signals
signal dialog_finished
signal choice_made(choice_index)

# Export variables
@export var ink_story_path: String = ""
@export var auto_start: bool = true
@export var text_speed: float = 0.02  # Time between characters when typing
@export var auto_continue_delay: float = 1.0  # Time before auto-continuing
@export var show_debug_info: bool = false

# Node references
@onready var dialog_text: RichTextLabel = $DialogPanel/DialogText
@onready var dialog_panel: Panel = $DialogPanel
@onready var choices_container: VBoxContainer = $ChoicesPanel/ChoicesContainer
@onready var character_name_label: Label = $DialogPanel/CharacterName
@onready var debug_label: Label = $DebugInfo
@onready var continue_indicator: TextureRect = $DialogPanel/ContinueIndicator

# Variables
var _gdink: GDInk = null
var _current_text: String = ""
var _displayed_text: String = ""
var _typing: bool = false
var _choices: Array = []
var _auto_continue_timer: Timer = null
var _typing_timer: Timer = null
var _choice_buttons: Array = []

# Ready function
func _ready():
    # Create a new GDInk instance
    _gdink = GDInk.new()
    add_child(_gdink)
    
    # Connect signals
    _gdink.story_continued.connect(_on_story_continued)
    _gdink.choices_available.connect(_on_choices_available)
    _gdink.variable_changed.connect(_on_variable_changed)
    _gdink.story_ended.connect(_on_story_ended)
    _gdink.error_encountered.connect(_on_error_encountered)
    
    # Create timers
    _auto_continue_timer = Timer.new()
    _auto_continue_timer.one_shot = true
    _auto_continue_timer.timeout.connect(_on_auto_continue_timeout)
    add_child(_auto_continue_timer)
    
    _typing_timer = Timer.new()
    _typing_timer.wait_time = text_speed
    _typing_timer.timeout.connect(_on_typing_timeout)
    add_child(_typing_timer)
    
    # Hide continue indicator initially
    if continue_indicator:
        continue_indicator.visible = false
    
    # Hide debug info if not enabled
    if debug_label:
        debug_label.visible = show_debug_info
    
    # Load story if specified
    if not ink_story_path.is_empty() and auto_start:
        load_story(ink_story_path)

# Process input
func _input(event):
    if event.is_action_pressed("ui_accept") or (event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT):
        # If typing, complete the text immediately
        if _typing:
            _complete_typing()
        # If there are no choices, continue the story
        elif _choices.is_empty():
            continue_story()
        
        get_viewport().set_input_as_handled()

# Load a story from file
func load_story(story_path):
    reset_ui()
    
    if _gdink.load_story(story_path):
        # Start the story
        continue_story()
        return true
    
    return false

# Continue the story
func continue_story():
    if _gdink:
        _gdink.continue_story()

# Make a choice
func make_choice(choice_index):
    if _gdink and choice_index >= 0 and choice_index < _choices.size():
        emit_signal("choice_made", choice_index)
        _gdink.choose(choice_index)
        
        # Clear choices UI
        for button in _choice_buttons:
            button.queue_free()
        _choice_buttons.clear()
        
        # Continue the story after making a choice
        continue_story()

# Reset the UI to initial state
func reset_ui():
    # Clear text
    if dialog_text:
        dialog_text.text = ""
    
    # Clear character name
    if character_name_label:
        character_name_label.text = ""
    
    # Clear choices
    for button in _choice_buttons:
        button.queue_free()
    _choice_buttons.clear()
    
    # Stop timers
    _typing_timer.stop()
    _auto_continue_timer.stop()
    
    # Reset variables
    _current_text = ""
    _displayed_text = ""
    _typing = false
    _choices = []
    
    # Hide continue indicator
    if continue_indicator:
        continue_indicator.visible = false

# Get a story variable
func get_variable(variable_name):
    if _gdink:
        return _gdink.get_variable(variable_name)
    return null

# Set a story variable
func set_variable(variable_name, value):
    if _gdink:
        return _gdink.set_variable(variable_name, value)
    return false

# Save the current state
func save_state():
    if _gdink:
        return _gdink.save_state()
    return null

# Load a previously saved state
func load_state(state_dict):
    if _gdink:
        if _gdink.load_state(state_dict):
            # Update UI
            continue_story()
            return true
    return false

# Handle story continued signal
func _on_story_continued(text, tags):
    # Process tags
    _process_tags(tags)
    
    # Set the text and start typing effect
    _current_text = text
    _displayed_text = ""
    _typing = true
    
    # Start typing timer
    if not _current_text.is_empty():
        _typing_timer.start()
    else:
        # Empty text, just show choices if any
        _typing = false
        if continue_indicator:
            continue_indicator.visible = _choices.is_empty()

# Handle typing timeout
func _on_typing_timeout():
    if _typing and dialog_text:
        if _displayed_text.length() < _current_text.length():
            _displayed_text += _current_text[_displayed_text.length()]
            dialog_text.text = _displayed_text
            _typing_timer.start()
        else:
            _complete_typing()

# Complete typing immediately
func _complete_typing():
    _typing = false
    _displayed_text = _current_text
    
    if dialog_text:
        dialog_text.text = _current_text
    
    # Show continue indicator if there are no choices
    if continue_indicator:
        continue_indicator.visible = _choices.is_empty()
    
    # If auto-continue is enabled and there are no choices, start the timer
    if _choices.is_empty() and auto_continue_delay > 0:
        _auto_continue_timer.wait_time = auto_continue_delay
        _auto_continue_timer.start()

# Handle auto-continue timeout
func _on_auto_continue_timeout():
    if _choices.is_empty():
        continue_story()

# Handle choices available signal
func _on_choices_available(choices):
    _choices = choices
    
    # Clear previous choices
    for button in _choice_buttons:
        button.queue_free()
    _choice_buttons.clear()
    
    # Create buttons for each choice
    for i in range(choices.size()):
        var choice = choices[i]
        var button = Button.new()
        button.text = choice.get("text", "Choice " + str(i + 1))
        button.pressed.connect(_on_choice_button_pressed.bind(i))
        
        choices_container.add_child(button)
        _choice_buttons.append(button)
    
    # Hide continue indicator if there are choices
    if continue_indicator:
        continue_indicator.visible = false

# Handle choice button pressed
func _on_choice_button_pressed(choice_index):
    make_choice(choice_index)

# Handle variable changed signal
func _on_variable_changed(variable_name, new_value):
    if show_debug_info and debug_label:
        debug_label.text = "Variable changed: " + variable_name + " = " + str(new_value)

# Handle story ended signal
func _on_story_ended():
    emit_signal("dialog_finished")
    
    if show_debug_info and debug_label:
        debug_label.text = "Story ended"

# Handle error encountered signal
func _on_error_encountered(message):
    if show_debug_info and debug_label:
        debug_label.text = "Error: " + message
    
    push_error("GDInkDialogUI error: " + message)

# Process tags from Ink
func _process_tags(tags):
    for tag in tags:
        tag = tag.strip_edges()
        
        # Handle character name tag
        if tag.begins_with("character:"):
            var character_name = tag.substr("character:".length()).strip_edges()
            if character_name_label:
                character_name_label.text = character_name
        
        # Handle other tags as needed
        # For example: mood, animations, backgrounds, etc.
        # Implement your own tag handling here