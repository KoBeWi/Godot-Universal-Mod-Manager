extends RefCounted

var game: String
var name: String
var description: String
var version: String
var dependencies: PackedStringArray

func load_data(path: String):
	pass

func save_data(path: String):
	var config_file := ConfigFile.new()
	config_file.set_value("Godot Mod", "game", game)
	config_file.set_value("Godot Mod", "name", name)
	config_file.set_value("Godot Mod", "description", description)
	config_file.set_value("Godot Mod", "version", version)
	config_file.save(path.path_join("mod.cfg"))
