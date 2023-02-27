extends VBoxContainer

enum {DIRECTORY_CREATE_GAME, DIRECTORY_ADD_GAME, DIRECTORY_ADD_DESCRIPTIOR}
var directory_mode: int = -1

var icon_formats := ["png", "jpg"]

func _ready() -> void:
	for game in Registry.games:
		add_game_entry(game)

func on_create_game_entry() -> void:
	%CreateTitle.clear()
	%CreateScene.clear()
	%CreateDirectory.clear()
	
	$CreateGame.reset_size()
	$CreateGame.popup_centered()

func validate_create() -> void:
	if %CreateTitle.text.is_empty():
		set_create_error("Title can't be empty.")
		## TODO: czy unikalne?
		return
	
	if not %CreateIcon.text.is_empty():
		if not %CreateIcon.text.get_extension() in icon_formats:
			set_create_error("Icon format invalid. Supported extensions: %s" % icon_formats)
			return
		
		if not FileAccess.file_exists(%CreateIcon.text):
			set_create_error("Icon file does not exist.")
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

func create_pick_icon() -> void:
	$FileDialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	$FileDialog.popup_centered_ratio(0.4)

func create_pick_directory() -> void:
	directory_mode = DIRECTORY_CREATE_GAME
	$FileDialog.file_mode = FileDialog.FILE_MODE_OPEN_DIR
	$FileDialog.popup_centered_ratio(0.4)

func on_directory_selected(dir: String) -> void:
	match directory_mode:
		DIRECTORY_CREATE_GAME:
			set_text(%CreateDirectory, dir)

func on_file_selected(path: String) -> void:
	set_text(%CreateIcon, path)

func create_game_entry() -> void:
	var entry := preload("res://Data/GameDescriptor.gd").new()
	entry.title = %CreateTitle.text
	entry.godot_version = %CreateVersion.get_item_text(%CreateVersion.selected)
	entry.main_scene = %CreateScene.text
	
	var entry_path: String = "user://Games/" + %CreateTitle.text.validate_filename()
	DirAccess.make_dir_recursive_absolute(entry_path)
	entry.save_data(entry_path)
	
	if not %CreateIcon.text.is_empty():
		var image := Image.load_from_file(%CreateIcon.text)
		image.resize(80, 80, Image.INTERPOLATE_LANCZOS)
		image.save_png(entry_path.path_join("icon.png"))
	
	var entry_data := {entry_path = entry_path, game_path = %CreateDirectory.text}
	Registry.games.append(entry_data)
	Registry.save_game_entry_list()
	add_game_entry(entry_data)

func add_game_entry(game: Dictionary):
	var entry = preload("res://Nodes/GameEntry.tscn").instantiate()
	%GameList.add_child(entry)
	entry.set_game(game.entry_path)
	entry.button.pressed.connect(open_game.bind(game.entry_path))

func open_game(path: String):
	get_tree().set_meta(&"current_game", path)
	get_tree().change_scene_to_file("res://Scenes/Game.tscn")

func set_text(edit: LineEdit, text: String):
	edit.text = text
	edit.text_changed.emit(text)
