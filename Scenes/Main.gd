extends VBoxContainer

enum { DIRECTORY_CREATE_GAME, DIRECTORY_ADD_GAME, DIRECTORY_ADD_DESCRIPTIOR }

@onready var game_list: VBoxContainer = %GameList
@onready var delete_confirm: ConfirmationDialog = %DeleteConfirm

@onready var add_game_dialog: AcceptDialog = %AddGame
@onready var import_path: HBoxContainer = %ImportPath
@onready var import_game: HBoxContainer = %ImportGame
@onready var copy_descriptor: CheckBox = %CopyLocal
@onready var add_error: Label = %AddError

@onready var create_game_dialog: AcceptDialog = %CreateGame
@onready var create_title: LineEdit = %CreateTitle
@onready var create_icon: HBoxContainer = %CreateIcon
@onready var create_version: OptionButton = %CreateVersion
@onready var create_scene: LineEdit = %CreateScene
@onready var create_directory: HBoxContainer = %CreateDirectory
@onready var create_error: Label = %CreateError

var directory_mode: int = -1
var entry_to_delete: Control

func _ready() -> void:
	var versions: Array = str_to_var(FileAccess.get_file_as_string("res://System/Versions.dat"))
	for dir in versions:
		create_version.add_item(dir)
	
	for game in Registry.games:
		add_game_entry(game)

func on_import_game_entry() -> void:
	import_path.clear()
	import_game.clear()
	copy_descriptor.button_pressed = true
	validate_add()
	
	add_game_dialog.reset_size()
	add_game_dialog.popup_centered()

func validate_add() -> void:
	if import_path.text.is_empty():
		set_add_error("Descriptor path can't be empty.")
		return
	
	if not FileAccess.file_exists(import_path.text.path_join("game.cfg")):
		set_add_error("Descriptor directory invalid. Missing \"game.cfg\".")
		return
	
	var data := GameDescriptor.new()
	data.load_data(import_path.text)
	for game in game_list.get_children():
		if game.entry.title == data.title:
			set_add_error("Game already on the list. Delete it first.")
			return
	
	if import_game.text.is_empty():
		set_add_error("Game directory name can't be empty.")
		return
	
	if DirAccess.get_files_at(import_game.text).is_empty():
		set_add_error("The provided directory does not contain any files.")
		return
	
	set_add_error("")

func set_add_error(error: String):
	add_error.text = error
	add_game_dialog.get_ok_button().disabled = not error.is_empty()

func import_game_entry() -> void:
	var entry_folder: String = import_game.text.simplify_path()
	
	if copy_descriptor.button_pressed:
		var entry := GameDescriptor.new()
		entry.load_data(entry_folder)
		
		var new_folder: String = "user://Games/" + entry.title.validate_filename()
		DirAccess.make_dir_recursive_absolute(new_folder)
		DirAccess.copy_absolute(entry_folder.path_join("game.cfg"), new_folder.path_join("game.cfg"))
		DirAccess.copy_absolute(entry_folder.path_join("icon.png"), new_folder.path_join("icon.png"))
		
		entry_folder = new_folder
	
	var entry_data := Registry.add_new_game_entry(entry_folder, import_game.text.simplify_path())
	add_game_entry(entry_data)

func on_create_game_entry() -> void:
	create_title.clear()
	create_scene.clear()
	create_directory.clear()
	validate_create()
	
	create_game_dialog.reset_size()
	create_game_dialog.popup_centered()

func validate_create() -> void:
	if create_title.text.is_empty():
		set_create_error("Title can't be empty.")
		return
	
	for game in game_list.get_children():
		if game.entry.title == create_title.text:
			set_create_error("Game already on the list.")
			return
	
	if not create_title.text.is_empty():
		if not create_icon.text.get_extension() in Registry.ICON_FORMATS:
			set_create_error("Icon format invalid. Supported extensions: %s" % ", ".join(Registry.ICON_FORMATS))
			return
		
		if not FileAccess.file_exists(create_icon.text):
			set_create_error("Icon file does not exist.")
			return
	
	if create_scene.text.is_empty():
		set_create_error("Scene can't be empty.")
		return
	
	if create_scene.text.begins_with("uid://"):
		pass
	elif not create_scene.text.begins_with("res://") or not create_scene.text.get_extension() in ["tscn", "scn"]:
		set_create_error("Scene path must be a UID, or point to a scn/tscn file inside res://.")
		return
	
	if create_directory.text.is_empty():
		set_create_error("Game directory name can't be empty.")
		return
	
	if not DirAccess.dir_exists_absolute(create_directory.text):
		set_create_error("The provided directory does not exist.")
		return
	
	if DirAccess.get_files_at(create_directory.text).is_empty():
		set_create_error("The provided directory does not contain any files.")
		return
	
	set_create_error("")

func set_create_error(error: String):
	create_error.text = error
	create_game_dialog.get_ok_button().disabled = not error.is_empty()

func create_game_entry() -> void:
	var entry := GameDescriptor.new()
	entry.title = create_title.text
	entry.godot_version = create_version.get_item_text(create_version.selected)
	entry.main_scene = create_scene.text
	
	var entry_path: String = "user://Games/" + create_title.text.validate_filename()
	DirAccess.make_dir_recursive_absolute(entry_path)
	entry.save_data(entry_path)
	
	if not create_icon.text.is_empty():
		var image := Image.load_from_file(create_icon.text)
		Registry.smart_resize_to_80(image)
		image.save_png(entry_path.path_join("icon.png"))
	
	var entry_data := Registry.add_new_game_entry(entry_path, create_directory.text.simplify_path())
	add_game_entry(entry_data)

func add_game_entry(game: Registry.GameData) -> Control:
	var entry = preload("res://Nodes/GameEntry.tscn").instantiate()
	game_list.add_child(entry)
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
		delete_confirm.dialog_text = "Delete game \"%s\"?" % entry.entry.title
		delete_confirm.reset_size()
		delete_confirm.popup_centered()
