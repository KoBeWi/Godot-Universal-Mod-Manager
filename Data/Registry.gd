extends Node

const GAME_ENTRIES_FILE = "user://game_list.txt"

var games: Array[GameData]

func _enter_tree() -> void:
	var game_entries := FileAccess.open(GAME_ENTRIES_FILE, FileAccess.READ)
	if game_entries:
		var game_list: Array = str_to_var(game_entries.get_as_text())
		for game in game_list:
			games.append(GameData.new(game))

func save_game_entry_list():
	var game_entries := FileAccess.open(GAME_ENTRIES_FILE, FileAccess.WRITE)
	var game_list := games.map(func(game: GameData) -> Dictionary: return game.get_var())
	game_entries.store_string(var_to_str(game_list))

func add_new_game_entry(entry_path: String, game_path: String) -> GameData:
	var game := GameData.new({entry_path = entry_path, game_path = game_path, installed_mods = []})
	games.append(game)
	save_game_entry_list()
	return game

func add_new_mod_entry(game: GameData, load_path: String) -> GameData.ModData:
	var mod := GameData.ModData.new({load_path = load_path, active = true})
	game.installed_mods.append(mod)
	save_game_entry_list()
	return mod

class GameData:
	class ModData:
		var load_path: String
		var active: bool
		
		func _init(data: Dictionary) -> void:
			load_path = data.load_path
			active = data.active
		
		func get_var() -> Dictionary:
			return {load_path = load_path, active = active}
	
	var entry_path: String
	var game_path: String
	var mods_enabled: bool
	var installed_mods: Array[ModData]
	
	func _init(data: Dictionary) -> void:
		entry_path = data.entry_path
		game_path = data.game_path
		mods_enabled = FileAccess.file_exists(game_path.path_join("GUMM_mod_loader.tscn"))
		
		for mod in data.installed_mods:
			installed_mods.append(ModData.new(mod))
	
	func get_var() -> Dictionary:
		var mods := installed_mods.map(func(mod: ModData) -> Dictionary: return mod.get_var())
		return {entry_path = entry_path, game_path = game_path, mods_enabled = mods_enabled, installed_mods = mods}
