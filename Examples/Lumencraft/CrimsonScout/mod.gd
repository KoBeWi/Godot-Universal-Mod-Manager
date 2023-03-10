extends "GUMM_mod.gd"

func _initialize(scene_tree):
    var dir = Directory.new()
    dir.open(get_full_path("mod://Textures"))
    dir.list_dir_begin(true, true)

    var file = dir.get_next()
    while file:
        var texture = load_texture("mod://Textures/".plus_file(file))
        replace_resource_at("res://Nodes/Player/Animations".plus_file(file), texture)
        file = dir.get_next()