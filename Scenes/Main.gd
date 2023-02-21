extends VBoxContainer

enum {DIRECTORY_CREATE_GAME, DIRECTORY_ADD_GAME, DIRECTORY_ADD_DESCRIPTIOR}
var directory_mode: int = -1

func on_create_game_entry() -> void:
	%CreateTitle.clear()
	%CreateScene.clear()
	%CreateDirectory.clear()
	
	$CreateGame.reset_size()
	$CreateGame.popup_centered()

func validate_create() -> void:
	if %CreateTitle.text.is_empty():
		set_create_error("Title can't be empty.")
		return
	
	if %CreateScene.text.is_empty():
		set_create_error("Scene can't be empty.")
		return
	
	if not %CreateScene.text.begins_with("res://") or not %CreateScene.text.get_extension() in ["tscn", "scn"]:
		set_create_error("Scene path needs to point to a scn/tscn file inside res://.")
		return
	
	if %CreateDirectory.text.is_empty():
		set_create_error("Game directory can't be empty.")
		return
	
	if DirAccess.get_files_at(%CreateDirectory.text).is_empty():
		set_create_error("The provided directory does not contain any files.")
		return
	
	set_create_error("")

func set_create_error(error: String):
	%CreateError.text = error
	$CreateGame.get_ok_button().disabled = not error.is_empty()

func create_pick_directory() -> void:
	directory_mode = DIRECTORY_CREATE_GAME
	$FileDialog.popup_centered_ratio(0.4)

func on_directory_selected(dir: String) -> void:
	match directory_mode:
		DIRECTORY_CREATE_GAME:
			%CreateDirectory.text = dir

func create_game_entry() -> void:
	pass # Replace with function body.
