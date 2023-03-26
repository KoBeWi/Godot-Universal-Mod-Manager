extends RefCounted
class_name GameDescriptor

var title: String
var godot_version: String
var main_scene: String

func load_data(path: String) -> bool:
	var config_file := ConfigFile.new()
	if config_file.load(path.path_join("game.cfg")) != OK:
		return false
	
	title = config_file.get_value("Godot Game", "title")
	godot_version = config_file.get_value("Godot Game", "godot_version")
	main_scene = config_file.get_value("Godot Game", "main_scene")
	return true

func save_data(path: String):
	var config_file := ConfigFile.new()
	config_file.set_value("Godot Game", "title", title)
	config_file.set_value("Godot Game", "godot_version", godot_version)
	config_file.set_value("Godot Game", "main_scene", main_scene)
	config_file.save(path.path_join("game.cfg"))
