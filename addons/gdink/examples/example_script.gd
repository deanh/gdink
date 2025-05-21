extends Node2D

@onready var dialog_ui = $GDInkDialogUI

func _ready():
    # Set up the dialog UI
    dialog_ui.ink_story_path = "res://addons/gdink/examples/basic_story.json"
    dialog_ui.auto_start = true
    dialog_ui.text_speed = 0.03
    dialog_ui.auto_continue_delay = 2.0
    dialog_ui.show_debug_info = true
    
    # Connect signals
    dialog_ui.dialog_finished.connect(_on_dialog_finished)
    dialog_ui.choice_made.connect(_on_choice_made)
    
    # You can also set variables programmatically
    dialog_ui.set_variable("player_name", "Godot Hero")

func _on_dialog_finished():
    print("Dialog story has ended")
    
func _on_choice_made(choice_index):
    print("Player made choice: ", choice_index)