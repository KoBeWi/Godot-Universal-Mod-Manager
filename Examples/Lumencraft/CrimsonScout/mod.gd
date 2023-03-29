extends "GUMM_mod.gd"

func _initialize(scene_tree):
    var dir = Directory.new()
    dir.open(get_full_path("mod://Textures")) # Textures folder relative to the mod.
    dir.list_dir_begin(true, true)

    var file = dir.get_next()
    while file:
        # Iterate mod files and replace the game ones.
        var texture = load_texture("mod://Textures/".plus_file(file))
        replace_resource_at("res://Nodes/Player/Animations".plus_file(file), texture)
        file = dir.get_next()
    
    replace_resource_at("res://SFX/Player/Male taking damage_01.wav", load_ogg("mod://Sounds/TakingDamage1.ogg"))
    replace_resource_at("res://SFX/Player/Male taking damage_02.wav", load_mp3("mod://Sounds/TakingDamage2.mp3"))
    replace_resource_at("res://SFX/Player/Male taking damage_03.wav", load_ogg("mod://Sounds/TakingDamage3.ogg"))