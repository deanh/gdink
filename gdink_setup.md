# GDInk Plugin for Godot 4.x
# This file contains setup instructions and example usage

# -----------------------
# PLUGIN SETUP
# -----------------------

# 1. Create the following directory structure in your Godot project:
# res://
# ├── addons/
# │   └── gdink/
# │       ├── plugin.cfg
# │       ├── gdink_plugin.gd
# │       ├── icons/
# │       │   ├── ink_file.svg
# │       │   └── ink_node.svg
# │       ├── src/
# │       │   ├── gdink.gd             (Main module)
# │       │   ├── ink_parser.gd        (Ink parser)
# │       │   └── gdink_dialog_ui.gd   (Dialog UI component)
# │       └── examples/
# │           ├── basic_story.ink      (Example Ink story)
# │           └── basic_dialog.tscn    (Example dialog scene)

# 2. Create plugin.cfg file with the following content:
"""
[plugin]
name="GDInk"
description="Ink narrative scripting language integration for Godot"
author="Your Name"
version="1.0.0"
script="gdink_plugin.gd"
"""

# 3. Create the gdink_plugin.gd file:

# -------- gdink_plugin.gd --------
"""
@tool
extends EditorPlugin

func _enter_tree():
    # Register custom types
    add_custom_type("GDInk", "Node", preload("res://addons/gdink/src/gdink.gd"), preload("res://addons/gdink/icons/ink_node.svg"))
    add_custom_type("InkParser", "Node", preload("res://addons/gdink/src/ink_parser.gd"), preload("res://addons/gdink/icons/ink_node.svg"))
    add_custom_type("GDInkDialogUI", "Control", preload("res://addons/gdink/src/gdink_dialog_ui.gd"), preload("res://addons/gdink/icons/ink_node.svg"))
    
    # Add Ink file icon
    var editor_interface = get_editor_interface()
    var file_system_dock = editor_interface.get_file_system_dock()
    file_system_dock.add_file_type_association("ink", preload("res://addons/gdink/icons/ink_file.svg"))

func _exit_tree():
    # Remove custom types
    remove_custom_type("GDInk")
    remove_custom_type("InkParser")
    remove_custom_type("GDInkDialogUI")
"""
# -------------------------

# 4. Copy the GDInk, InkParser, and GDInkDialogUI classes to their respective files in the src/ directory.

# 5. Create a simple SVG icon for ink files and the ink node:

# -------- ink_file.svg --------
"""
<svg width="16" height="16" xmlns="http://www.w3.org/2000/svg">
  <rect x="1" y="1" width="14" height="14" rx="2" fill="#4b7bec" stroke="#2b5bcc" stroke-width="1"/>
  <text x="8" y="12" font-family="Arial" font-size="12" font-weight="bold" text-anchor="middle" fill="white">I</text>
</svg>
"""

# -------- ink_node.svg --------
"""
<svg width="16" height="16" xmlns="http://www.w3.org/2000/svg">
  <circle cx="8" cy="8" r="7" fill="#4b7bec" stroke="#2b5bcc" stroke-width="1"/>
  <text x="8" y="12" font-family="Arial" font-size="12" font-weight="bold" text-anchor="middle" fill="white">I</text>
</svg>
"""

# 6. Enable the plugin in Godot: Project > Project Settings > Plugins > GDInk > Enable

# -----------------------
# EXAMPLE INK STORY
# -----------------------

# Create a basic Ink story file in examples/basic_story.ink:

"""
# basic_story.ink
# A simple example of an Ink script

VAR player_name = "Adventurer"
VAR health = 100
VAR has_sword = false

=== start ===
# character: Narrator
Welcome, {player_name}! Your adventure begins here.

* [Look around] -> look_around
* [Check inventory] -> check_inventory
* [Talk to stranger] -> talk_to_stranger

=== look_around ===
# character: Narrator
You find yourself in a dimly lit tavern. The air is thick with smoke and the smell of ale.

There's a mysterious stranger sitting in the corner, watching you carefully.
A rusty sword hangs on the wall.

* [Take the sword] -> take_sword
* [Approach the stranger] -> talk_to_stranger
* [Leave the tavern] -> leave_tavern

=== take_sword ===
# character: Narrator
You grab the sword from the wall. It's old but still sharp.
~ has_sword = true

* [Continue] -> look_around

=== check_inventory ===
# character: Narrator
You have:
{has_sword: A rusty sword}
{not has_sword: No weapons}
Health: {health}

* [Return] -> start

=== talk_to_stranger ===
# character: Stranger
Hello there, {player_name}. I've been waiting for someone like you.

* [Ask about the quest]
    # character: You
    What's this quest you speak of?
    
    # character: Stranger
    The village to the north is in danger. They need a brave soul to defend them.
    
    * * [Accept the quest] -> accept_quest
    * * [Decline] -> decline_quest

* [Leave] -> look_around

=== accept_quest ===
# character: Stranger
Excellent! Take this map and head north at dawn.

{has_sword: The sword you found will serve you well.}
{not has_sword: You might want to find a weapon first.}

* [End conversation] -> look_around

=== decline_quest ===
# character: Stranger
Perhaps another time then. The offer remains open.

* [End conversation] -> look_around

=== leave_tavern ===
# character: Narrator
You step outside into the cool night air. The village is quiet.

This is the end of our demo.
-> END
"""

# -----------------------
# DIALOG UI SETUP
# -----------------------

# Create a simple dialog UI scene in Godot:

"""
# DialogUI.tscn
- GDInkDialogUI (Control)
  - DialogPanel (Panel)
    - CharacterName (Label)
    - DialogText (RichTextLabel)
    - ContinueIndicator (TextureRect)
  - ChoicesPanel (Panel)
    - ChoicesContainer (VBoxContainer)
  - DebugInfo (Label)
"""

# -----------------------
# USAGE EXAMPLE
# -----------------------

# Create a simple scene that uses the GDInk system:

"""
# MainScene.tscn
- Main (Node2D)
  - GDInkDialogUI
  - ExampleScript (attached script)
"""

# Example script to use with the dialog system:

# -------- example_script.gd --------
"""
extends Node2D

@onready var dialog_ui = $GDInkDialogUI

func _ready():
    # Set up the dialog UI
    dialog_ui.ink_story_path = "res://addons/gdink/examples/basic_story.ink.json"
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
"""

# -----------------------
# CONVERTING INK TO JSON
# -----------------------

# To use Ink files in Godot, they need to be compiled to JSON format first.
# There are two ways to do this:

# Option 1: Use the Ink compiler directly
# 1. Install the Ink compiler from https://github.com/inkle/ink/releases
# 2. Run the compiler on your .ink files:
#    inklecate -o output.json your_story.ink

# Option 2: Use the built-in InkCompiler class
# This requires setting up the Ink compiler in your project:

# -------- compile_ink.gd --------
"""
extends SceneTree

func _init():
    # Path to your Ink compiler
    var compiler_path = "path/to/inklecate"
    
    # Create the compiler
    var ink_compiler = GDInk.InkCompiler.new(compiler_path)
    
    # Compile an .ink file to JSON
    var result = ink_compiler.compile_ink_to_json("res://addons/gdink/examples/basic_story.ink")
    
    if result == OK:
        print("Compilation successful!")
    else:
        print("Failed to compile Ink file. Error code: ", result)
    
    quit()
"""

# Run this script with: godot --script compile_ink.gd

# -----------------------
# ADVANCED USAGE
# -----------------------

# Extending GDInk with custom functions:

# -------- custom_ink_functions.gd --------
"""
extends GDInk

# Custom external functions for Ink

func _init():
    super()
    # Register external functions here
    # This would require extending the Ink parser

# Example of a custom function that could be called from Ink
func rand_range(min_val, max_val):
    return randf_range(float(min_val), float(max_val))
"""

# Using save/load functionality:

# -------- save_load_example.gd --------
"""
extends Node

@onready var dialog_ui = $GDInkDialogUI

func save_game():
    var save_data = {
        "story_state": dialog_ui.save_state(),
        "other_game_data": {
            "player_position": $Player.position,
            "game_time": get_game_time()
        }
    }
    
    var file = FileAccess.open("user://save_game.json", FileAccess.WRITE)
    if file:
        file.store_string(JSON.stringify(save_data))
        file.close()
        return true
    return false

func load_game():
    var file = FileAccess.open("user://save_game.json", FileAccess.READ)
    if file:
        var json = JSON.new()
        var error = json.parse(file.get_as_text())
        file.close()
        
        if error == OK:
            var save_data = json.get_data()
            
            # Load story state
            dialog_ui.load_state(save_data.story_state)
            
            # Load other game data
            $Player.position = save_data.other_game_data.player_position
            set_game_time(save_data.other_game_data.game_time)
            
            return true
    return false
"""

# -----------------------
# TROUBLESHOOTING
# -----------------------

# Common issues and solutions:

# 1. Issue: "No story loaded" error
#    Solution: Make sure the path to the .ink.json file is correct and the file exists

# 2. Issue: Characters aren't displaying properly
#    Solution: Check that you're using the correct tag format in your Ink file (e.g., # character: Name)

# 3. Issue: Can't compile Ink files
#    Solution: Ensure the Ink compiler (inklecate) is properly installed and accessible

# 4. Issue: Choices not displaying
#    Solution: Verify your Ink syntax for choices is correct (* [Choice text])

# 5. Issue: Variables not updating
#    Solution: Check the variable declarations in Ink (VAR name = value) and ensure the names match

# For more information and support, visit:
# - Ink documentation: https://github.com/inkle/ink/blob/master/Documentation/WritingWithInk.md
# - Inkle's Discord: https://discord.gg/inkle