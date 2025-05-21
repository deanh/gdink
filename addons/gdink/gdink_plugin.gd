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
    # Note: For Godot 4.x, this method might change, check the Godot API
    # file_system_dock.add_file_type_association("ink", preload("res://addons/gdink/icons/ink_file.svg"))
    
    print("GDInk plugin initialized")

func _exit_tree():
    # Remove custom types
    remove_custom_type("GDInk")
    remove_custom_type("InkParser")
    remove_custom_type("GDInkDialogUI")
    
    print("GDInk plugin cleaned up")