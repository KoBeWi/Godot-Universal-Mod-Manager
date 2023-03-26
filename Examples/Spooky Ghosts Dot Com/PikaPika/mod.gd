extends "GUMM_mod.gd"

func _initialize(scene_tree):
	replace_resource_at("res://assets/player/laser.png", load_texture("mod://Textures/laser.png", 0))
	replace_resource_at("res://assets/player/player-sit.png", load_texture("mod://Textures/player-sit.png", 0))
	replace_resource_at("res://assets/player/player-dead.png", load_texture("mod://Textures/player-dead.png, 0"))
	replace_resource_at("res://assets/player/player-gun.png", load_texture("mod://Textures/player-gun.png", 0))
	replace_resource_at("res://assets/player/player-gun-down.png", load_texture("mod://Textures/player-gun-down.png", 0))
	replace_resource_at("res://assets/player/player-gun-up.png", load_texture("mod://Textures/player-gun-up.png", 0))
	replace_resource_at("res://assets/player/player-jump.png", load_texture("mod://Textures/player-jump.png", 0))
	replace_resource_at("res://assets/player/player-run.png", load_texture("mod://Textures/player-run.png", 0))
	replace_resource_at("res://assets/player/player-shoot-down-run.png", load_texture("mod://Textures/player-shoot-down-run.png", 0))
	replace_resource_at("res://assets/player/player-shoot-up-run.png", load_texture("mod://Textures/player-shoot-up-run.png", 0))