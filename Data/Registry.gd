extends Node

const GAME_ENTRIES_FILE = "user://game_list.txt"
const ICON_FORMATS: PackedStringArray = ["png", "jpg"]

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
	
	for mod_meta in game.installed_mods:
		if mod_meta.entry.name == mod.entry.name:
			mod_meta.load_path = load_path
			return mod_meta
	
	game.installed_mods.append(mod)
	save_game_entry_list()
	return mod

func remove_game_entry(game: GameData):
	games.erase(game)
	save_game_entry_list()

func remove_mod_entry(game: GameData, mod: GameData.ModData):
	game.installed_mods.erase(mod)
	save_game_entry_list()

func smart_resize_to_80(image: Image):
	if image.get_width() == image.get_height():
		image.resize(80, 80, Image.INTERPOLATE_LANCZOS)
	elif image.get_width() > image.get_height():
		image.resize(80, int(80.0 * image.get_height() / image.get_width()))
	elif image.get_width() < image.get_height():
		image.resize(int(80.0 * image.get_width() / image.get_height()), 80)
	else:
		get_tree().quit(1) # impossible

class GameData:
	class ModData:
		var load_path: String
		var active: bool
		var entry: ModDescriptor
		
		func _init(data: Dictionary) -> void:
			load_path = data.load_path
			active = data.active
			
			entry = ModDescriptor.new()
			if not entry.load_data(load_path):
				active = false
		
		func get_var() -> Dictionary:
			return {load_path = load_path, active = active}
	
	var entry: GameDescriptor
	var entry_path: String
	var game_path: String
	var mods_enabled: bool
	var installed_mods: Array[ModData]
	
	func _init(data: Dictionary) -> void:
		entry_path = data.entry_path
		game_path = data.game_path
		mods_enabled = FileAccess.file_exists(game_path.path_join("GUMM_mod_loader.tscn"))
		
		entry = GameDescriptor.new()
		entry.load_data(entry_path)
		
		for mod in data.installed_mods:
			installed_mods.append(ModData.new(mod))
	
	func get_var() -> Dictionary:
		var mods := installed_mods.map(func(mod: ModData) -> Dictionary: return mod.get_var())
		return {entry_path = entry_path, game_path = game_path, mods_enabled = mods_enabled, installed_mods = mods}
