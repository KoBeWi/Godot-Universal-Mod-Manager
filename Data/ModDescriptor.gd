extends RefCounted
class_name ModDescriptor

var game: String
var name: String
var description: String
var version: String
var dependencies: PackedStringArray

func load_data(path: String) -> bool:
	var config_file := ConfigFile.new()
	if config_file.load(path.path_join("mod.cfg")) != OK:
		return false
	
	game = config_file.get_value("Godot Mod", "game")
	name = config_file.get_value("Godot Mod", "name")
	description = config_file.get_value("Godot Mod", "description")
	version = config_file.get_value("Godot Mod", "version")
	
	return true

func save_data(path: String):
	var config_file := ConfigFile.new()
	config_file.set_value("Godot Mod", "game", game)
	config_file.set_value("Godot Mod", "name", name)
	config_file.set_value("Godot Mod", "description", description)
	config_file.set_value("Godot Mod", "version", version)
	config_file.save(path.path_join("mod.cfg"))
