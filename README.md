# GDInk

An integration of the [Ink narrative scripting language](https://www.inklestudios.com/ink/) for Godot 4.x.

## Features

- Parse and run Ink stories in Godot
- Interactive dialog system with choices
- Variable tracking and state management
- Tag support for character names and other metadata
- Simple dialog UI component ready to use or customize

## Installation

1. Copy the `addons/gdink` folder to your Godot project's `addons` directory
2. Enable the plugin in Godot: Project > Project Settings > Plugins > GDInk > Enable

## Getting Started

### 1. Set up an Ink Story

1. Create an Ink file (e.g., `story.ink`) using the [Ink syntax](https://github.com/inkle/ink/blob/master/Documentation/WritingWithInk.md)
2. Compile it to JSON using either:
   - The provided `compile_ink.sh` script in the `tools` directory
   - The [Inky editor](https://github.com/inkle/inky)
   - The [inklecate compiler](https://github.com/inkle/ink/releases)

### 2. Set up the Dialog UI

Option 1: Using the built-in dialog UI
```gdscript
# Create a GDInkDialogUI instance
var dialog_ui = GDInkDialogUI.new()
add_child(dialog_ui)

# Configure it
dialog_ui.ink_story_path = "res://path/to/story.json"
dialog_ui.auto_start = true
```

Option 2: Creating your own UI
```gdscript
# Create a GDInk instance
var ink = GDInk.new()
add_child(ink)

# Connect signals
ink.story_continued.connect(_on_story_continued)
ink.choices_available.connect(_on_choices_available)
ink.story_ended.connect(_on_story_ended)

# Load and start the story
ink.load_story("res://path/to/story.json")
ink.continue_story()
```

## Example

Check out the included example in the `examples` directory:

- `basic_story.ink` - A sample Ink story
- `basic_dialog.tscn` - A scene demonstrating the dialog UI
- `example_script.gd` - Script showing how to use GDInk

## Documentation

### GDInk Class

The main class for interacting with Ink stories:

- `load_story(json_file_path)` - Load a story from a JSON file
- `continue_story()` - Continue to the next passage
- `choose(choice_index)` - Make a choice
- `get_choices()` - Get available choices
- `is_story_ended()` - Check if the story has ended
- `get_variable(variable_name)` - Get a variable value
- `set_variable(variable_name, value)` - Set a variable value
- `save_state()` - Save the current state
- `load_state(state_dict)` - Load a previously saved state

### GDInkDialogUI Class

A ready-to-use dialog UI for Ink stories:

- `load_story(story_path)` - Load a story
- `continue_story()` - Continue to the next passage
- `make_choice(choice_index)` - Make a choice
- `reset_ui()` - Reset the UI
- `get_variable(variable_name)` - Get a variable value
- `set_variable(variable_name, value)` - Set a variable value
- `save_state()` - Save the current state
- `load_state(state_dict)` - Load a previously saved state

## Troubleshooting

- **"No story loaded" error**: Make sure the path to the .ink.json file is correct
- **Characters aren't displaying properly**: Check tag format (e.g., `# character: Name`)
- **Can't compile Ink files**: Ensure inklecate is installed correctly
- **Choices not displaying**: Verify Ink syntax for choices is correct (`* [Choice text]`)
- **Variables not updating**: Check variable declarations match in Ink and GDScript

## License

This project is available under the MIT License.

## Credits

- [Ink](https://github.com/inkle/ink) by Inkle Studios
- GDInk contributors# gdink
