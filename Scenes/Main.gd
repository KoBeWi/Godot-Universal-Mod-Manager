extends VBoxContainer

enum {DIRECTORY_CREATE_GAME, DIRECTORY_ADD_GAME, DIRECTORY_ADD_DESCRIPTIOR}
var directory_mode: int = -1

var entry_to_delete: Control

func _ready() -> void:
	for game in Registry.games:
		add_game_entry(game)

func on_add_game_entry() -> void:
	%ImportPath.clear()
	%ImportGame.clear()
	%CopyLocal.button_pressed = true
	validate_add()
	
	$AddGame.reset_size()
	$AddGame.popup_centered()

func validate_add() -> void:
	if %ImportPath.text.is_empty():
		set_add_error("Descriptor path can't be empty.")
		return
	
	if not FileAccess.file_exists(%ImportPath.text.path_join("game.cfg")):
		set_add_error("Descriptor directory invalid. Missing \"game.cfg\".")
		return
	
	var data := GameDescriptor.new()
	data.load_data(%ImportPath.text)
	for game in %GameList.get_children():
		if game.entry.title == data.title:
			set_add_error("Game already on the list. Delete it first.")
			return
	
	if %ImportGame.text.is_empty():
		set_add_error("Game directory name can't be empty.")
		return
	
	if DirAccess.get_files_at(%ImportGame.text).is_empty():
		set_add_error("The provided directory does not contain any files.")
		return
	
	set_add_error("")

func set_add_error(error: String):
	%AddError.text = error
	$AddGame.get_ok_button().disabled = not error.is_empty()

func import_game_entry() -> void:
	var entry_folder: String = %ImportPath.text.simplify_path()
	
	if %CopyLocal.button_pressed:
		var entry := GameDescriptor.new()
		entry.load_data(entry_folder)
		
		var new_folder: String = "user://Games/" + entry.title.validate_filename()
		DirAccess.make_dir_recursive_absolute(new_folder)
		DirAccess.copy_absolute(entry_folder.path_join("game.cfg"), new_folder.path_join("game.cfg"))
		DirAccess.copy_absolute(entry_folder.path_join("icon.png"), new_folder.path_join("icon.png"))
		
		entry_folder = new_folder
	
	var entry_data := Registry.add_new_game_entry(entry_folder, %ImportGame.text.simplify_path())
	add_game_entry(entry_data)

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
	
	for game in %GameList.get_children():
		if game.entry.title == %CreateTitle.text:
			set_create_error("Game already on the list.")
			return
	
	if not %CreateIcon.text.is_empty():
		if not %CreateIcon.text.get_extension() in Registry.ICON_FORMATS:
			set_create_error("Icon format invalid. Supported extensions: %s" % ", ".join(Registry.ICON_FORMATS))
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
		set_create_error("Game directory name can't be empty.")
		return
	
	if DirAccess.get_files_at(%CreateDirectory.text).is_empty():
		set_create_error("The provided directory does not contain any files.")
		return
	
	set_create_error("")

func set_create_error(error: String):
	%CreateError.text = error
	$CreateGame.get_ok_button().disabled = not error.is_empty()

func create_game_entry() -> void:
	var entry := GameDescriptor.new()
	entry.title = %CreateTitle.text
	entry.godot_version = %CreateVersion.get_item_text(%CreateVersion.selected)
	entry.main_scene = %CreateScene.text
	
	var entry_path: String = "user://Games/" + %CreateTitle.text.validate_filename()
	DirAccess.make_dir_recursive_absolute(entry_path)
	entry.save_data(entry_path)
	
	if not %CreateIcon.text.is_empty():
		var image := Image.load_from_file(%CreateIcon.text)
		Registry.smart_resize_to_80(image)
		image.save_png(entry_path.path_join("icon.png"))
	
	var entry_data := Registry.add_new_game_entry(entry_path, %CreateDirectory.text.simplify_path())
	add_game_entry(entry_data)

func add_game_entry(game: Registry.GameData) -> Control:
	var entry = preload("res://Nodes/GameEntry.tscn").instantiate()
	%GameList.add_child(entry)
	entry.owner = self
	entry.set_game(game)
	if not entry.missing:
		entry.button.pressed.connect(open_game.bind(game.entry_path))
	entry.get_node(^"%Remove").pressed.connect(remove_game.bind(entry))
	return entry

func open_game(path: String):
	get_tree().set_meta(&"current_game", path)
	get_tree().change_scene_to_file("res://Scenes/Game.tscn")

func set_text(edit: LineEdit, text: String):
	edit.text = text
	edit.text_changed.emit(text)

func refresh_entry(old_entry: Control):
	var new_entry := add_game_entry(old_entry.metadata)
	new_entry.get_parent().move_child(new_entry, old_entry.get_index())
	old_entry.queue_free()

func remove_game(entry, confirmed := false):
	if confirmed:
		entry = entry_to_delete
		entry.missing = true
	
	if entry.missing:
		Registry.remove_game_entry(entry.metadata)
		entry.queue_free()
	else:
		entry_to_delete = entry
		$DeleteConfirm.dialog_text = "Delete game \"%s\"?" % entry.entry.title
		$DeleteConfirm.reset_size()
		$DeleteConfirm.popup_centered()
