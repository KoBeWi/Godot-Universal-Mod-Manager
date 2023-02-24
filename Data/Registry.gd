extends Node

const GAME_ENTRIES_FILE = "user://game_list.txt"

var games: Array

func _enter_tree() -> void:
	var game_entries := FileAccess.open(GAME_ENTRIES_FILE, FileAccess.READ)
	if game_entries:
		Registry.games = str_to_var(game_entries.get_as_text())

func save_game_entry_list():
	var game_entries := FileAccess.open(GAME_ENTRIES_FILE, FileAccess.WRITE)
	game_entries.store_string(var_to_str(games))
