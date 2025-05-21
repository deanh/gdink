extends SceneTree

func _init():
    # Path to your Ink compiler - this would need to be updated for the user's system
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