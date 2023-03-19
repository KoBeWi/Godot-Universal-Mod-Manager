extends Control

var game_data: RefCounted
var game_metadata: Registry.GameData

var entry_to_update: Control
var entry_to_delete: Control

func _ready() -> void:
	game_data = GameDescriptor.new()
	game_data.load_data(get_tree().get_meta(&"current_game", ""))
	for meta in Registry.games:
		if meta.entry_path == game_data.file_path:
			game_metadata = meta
			break
	
	var new_missing: bool
	for mod in game_metadata.installed_mods:
		var active := mod.active
		add_mod_entry(mod)
		if not mod.active:
			new_missing = true
	
	if new_missing:
		apply_mods()
	
	%GameTitle.text = game_data.title
	%GameIcon.texture = ImageTexture.create_from_image(Image.load_from_file(game_data.file_path.path_join("icon.png")))
	%GodotVersion.text %= game_data.godot_version
	%ModsEnabled.set_pressed_no_signal(game_metadata.mods_enabled)

func import_mod() -> void:
	import_mod_update()
	$ImportModDialog.popup_centered()

func import_mod_update() -> void:
	## TODO: sprawdzanie, czy istnieje. Jak tak to aktualizować (i pisać wersje)
	%ImportModName.text = ""
	%ImportModDescription.text = ""
	%ImportModVersion.text = ""
	
	if %ImportModPath.text.is_empty():
		set_import_error("Path can't be empty.")
		return
	
	if not DirAccess.dir_exists_absolute(%ImportModPath.text):
		set_import_error("The provided directory does not exist.")
		return
	
	if not FileAccess.file_exists(%ImportModPath.text.path_join("mod.cfg")):
		set_import_error("No \"mod.cfg\" found at the given location.")
		return
	
	var mod_data := ModDescriptor.new()
	mod_data.load_data(%ImportModPath.text.path_join("mod.cfg"))
	
	if mod_data.game != game_data.title:
		set_import_error("Mod isn't made for \"%s\"." % game_data.title)
		return
	
	%ImportModName.text = mod_data.name
	%ImportModDescription.text = mod_data.description
	%ImportModVersion.text = mod_data.version
	
	set_import_error("")

func set_import_error(error: String):
	%ImportError.text = error
	$ImportModDialog.get_ok_button().disabled = not error.is_empty()

func import_mod_confirmed() -> void:
	var entry := Registry.add_new_mod_entry(game_metadata, %ImportModPath.text)
	add_mod_entry(entry)
	apply_mods()

func add_mod_entry(mod: Registry.GameData.ModData) -> Control:
	var entry: Control = preload("res://Nodes/ModEntry.tscn").instantiate()
	%ModList.add_child(entry)
	entry.owner = self
	entry.set_mod(mod)
	
	entry.get_node(^"%Edit").pressed.connect(edit_mod.bind(entry))
	entry.get_node(^"%Remove").pressed.connect(remove_mod.bind(entry))
	return entry

func create_mod() -> void:
	entry_to_update = null
	%NewModPath.disabled = false
	%NewModPath.clear()
	%IconPath.disabled = false
	%IconPath.clear()
	%NewModDescription.clear()
	%NewModVersion.clear()
	$NewModDialog.popup_centered()

func begin_edit_mod() -> void:
	%NewModPath.disabled = true
	%NewModPath.text = entry_to_update.metadata.load_path
	%NewModName.text = entry_to_update.entry.name
	%NewModDescription.text = entry_to_update.entry.description
	%NewModVersion.text = entry_to_update.entry.version
	if entry_to_update.has_icon:
		%IconPath.disabled = true
		%IconPath.clear()
	else:
		%IconPath.disabled = false
	validate_new_mod()
	$NewModDialog.popup_centered()

func validate_new_mod():
	if %NewModPath.text.is_empty():
		set_create_error("Path can't be empty.")
		return
	
	if not DirAccess.dir_exists_absolute(%NewModPath.text):
		set_create_error("The provided directory does not exist.")
		return
	
	if not %NewModPath.disabled and not DirAccess.get_files_at(%NewModPath.text).is_empty():
		set_create_error("The selected directory must not contain any files.")
		return
	
	if %NewModName.text.is_empty():
		set_create_error("Mod name can't be empty.")
		return
	
	set_create_error("")
	
	if not %IconPath.disabled and (%IconPath.text.is_empty() or not FileAccess.file_exists(%IconPath.text) or not %IconPath.text.get_extension() in Registry.ICON_FORMATS):
		set_create_warning("Icon path invalid. The mod will have no icon.")

func set_create_error(error: String):
	%NewModError.add_theme_color_override(&"font_color", Color.RED)
	%NewModError.text = error
	$NewModDialog.get_ok_button().disabled = not error.is_empty()

func set_create_warning(warning: String):
	%NewModError.add_theme_color_override(&"font_color", Color.YELLOW)
	%NewModError.text = warning

func create_mod_confirmed() -> void:
	var mod_data := ModDescriptor.new()
	mod_data.game = game_data.title
	mod_data.name = %NewModName.text
	mod_data.description = %NewModDescription.text
	mod_data.version = %NewModVersion.text
	mod_data.save_data(%NewModPath.text)
	
	if not %IconPath.text.is_empty() and FileAccess.file_exists(%IconPath.text) and %IconPath.text.get_extension() in Registry.ICON_FORMATS:
		var image := Image.load_from_file(%IconPath.text)
		if image:
			Registry.smart_resize_to_80(image)
			image.save_png(%NewModPath.text.path_join("icon.png"))
	
	if entry_to_update:
		refresh_entry(entry_to_update)
		return
	
	DirAccess.copy_absolute("res://System/%s/GUMM_mod.gd" % game_data.godot_version, %NewModPath.text.path_join("GUMM_mod.gd"))
	DirAccess.copy_absolute("res://System/%s/mod.gd" % game_data.godot_version, %NewModPath.text.path_join("mod.gd"))
	
	var mod_entry := Registry.add_new_mod_entry(game_metadata, %NewModPath.text)
	add_mod_entry(mod_entry)
	apply_mods()

func open_game_directory() -> void:
	OS.shell_open(game_metadata.game_path)

func toggle_mods(button_pressed: bool) -> void:
	game_metadata.mods_enabled = button_pressed
	
	if button_pressed:
		apply_mods()
	else:
		var override_file := get_override_path()
		var config := ConfigFile.new()
		config.load(override_file)
		
		var deleted: bool
		var config_sections := config.get_sections()
		if config_sections.size() == 1 or config_sections.size() == 2:
			var has: int
			has += int("application" in config_sections)
			has += int("gumm" in config_sections)
			
			if has == config_sections.size():
				match game_data.godot_version:
						"3.x":
							if config.get_section_keys("application").size() == 1:
								DirAccess.remove_absolute(override_file)
								deleted = true
		
		if not deleted:
			match game_data.godot_version:
				"3.x":
					config.erase_section_key("application", "run/main_scene")
			
			if config.has_section("gumm"):
				config.erase_section("gumm")
			config.save(override_file)
		
		DirAccess.remove_absolute(game_metadata.game_path.path_join("GUMM_mod_loader.tscn"))

func apply_mods():
	var override_file := get_override_path()
	var config := ConfigFile.new()
	if FileAccess.file_exists(override_file):
		config.load(override_file)
	
	match game_data.godot_version:
		"3.x":
			config.set_value("application", "run/main_scene", "res://GUMM_mod_loader.tscn")
			DirAccess.copy_absolute("res://System/3.x/GUMM_mod_loader.tscn", game_metadata.game_path.path_join("GUMM_mod_loader.tscn"))
	
	config.set_value("gumm", "main_scene", game_data.main_scene)
	config.set_value("gumm", "mod_list", game_metadata.installed_mods.filter(func(mod): return mod.active).map(func(mod): return mod.load_path))
	
	config.save(override_file)

func edit_mod(entry):
	entry_to_update = entry
	begin_edit_mod()

func remove_mod(entry, confirmed := false):
	if confirmed:
		entry = entry_to_delete
		entry.missing = true
	
	if entry.missing:
		Registry.remove_mod_entry(game_metadata, entry.metadata)
		entry.queue_free()
	else:
		entry_to_delete = entry
		$DeleteConfirm.dialog_text = "Delete mod \"%s\"?" % entry.entry.name
		$DeleteConfirm.popup_centered()

func refresh_entry(old_entry: Control):
	var new_entry := add_mod_entry(old_entry.metadata)
	new_entry.get_parent().move_child(new_entry, old_entry.get_index())
	old_entry.queue_free()

func get_override_path() -> String:
	return game_metadata.game_path.path_join("override.cfg")

func go_back() -> void:
	get_tree().change_scene_to_file("res://Scenes/Main.tscn")
