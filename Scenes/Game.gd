extends Control

var game_data: RefCounted
var game_metadata: Registry.GameData

func _ready() -> void:
	game_data = preload("res://Data/GameDescriptor.gd").new()
	game_data.load_data(get_tree().get_meta(&"current_game", ""))
	for meta in Registry.games:
		if meta.entry_path == game_data.file_path:
			game_metadata = meta
			break
	
	%GameTitle.text = game_data.title
	%GameIcon.texture = ImageTexture.create_from_image(Image.load_from_file(game_data.file_path.path_join("icon.png")))
	%GodotVersion.text %= game_data.godot_version
	%ModsEnabled.set_pressed_no_signal(FileAccess.file_exists(game_metadata.game_path.path_join("GUMM_mod_loader.tscn")))

func import_mod() -> void:
	import_mod_update()
	$ImportModDialog.popup_centered()

func import_mod_update() -> void:
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
	
	var mod_data := preload("res://Data/ModDescriptor.gd").new()
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
	pass # Replace with function body.

func create_mod() -> void:
	%NewModPath.clear()
	%NewModName.clear()
	%NewModDescription.clear()
	%NewModVersion.clear()
	$NewModDialog.popup_centered()

func validate_new_mod():
	if %NewModPath.text.is_empty():
		set_create_error("Path can't be empty.")
		return
	
	if not DirAccess.dir_exists_absolute(%NewModPath.text):
		set_create_error("The provided directory does not exist.")
		return
	
	if not DirAccess.get_files_at(%NewModPath.text).is_empty():
		set_create_error("The selected directory must not contain any files.")
		return
	
	if %NewModName.text.is_empty():
		set_create_error("Mod name can't be empty.")
		return
	
	set_create_error("")

func set_create_error(error: String):
	%NewModError.text = error
	$NewModDialog.get_ok_button().disabled = not error.is_empty()

func create_mod_confirmed() -> void:
	var mod_data := preload("res://Data/ModDescriptor.gd").new()
	mod_data.game = game_data.title
	mod_data.name = %NewModName.text
	mod_data.description = %NewModDescription.text
	mod_data.version = %NewModVersion.text
	mod_data.save_data(%NewModPath.text)
	
	DirAccess.copy_absolute("res://System/%s/GUMM_mod.gd" % game_data.godot_version, %NewModPath.text.path_join("GUMM_mod.gd"))

func open_game_directory() -> void:
	OS.shell_open(game_metadata.game_path)

func toggle_mods(button_pressed: bool) -> void:
	var override_file: String = game_metadata.game_path.path_join("override.cfg")
	var config := ConfigFile.new()
	
	if button_pressed:
		if FileAccess.file_exists(override_file):
			config.load(override_file)
		
		match game_data.godot_version:
			"3.x":
				config.set_value("application", "run/main_scene", "res://GUMM_mod_loader.tscn")
				DirAccess.copy_absolute("res://System/3.x/GUMM_mod_loader.tscn", game_metadata.game_path.path_join("GUMM_mod_loader.tscn"))
		
		config.set_value("gumm", "main_scene", game_data.main_scene)
		config.set_value("gumm", "mod_list", ["X:/Godot/Projects/GUMM/Examples/Lumencraft/CrimsonScout"])
		
		config.save(override_file)
	else:
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

func go_back() -> void:
	get_tree().change_scene_to_file("res://Scenes/Main.tscn")
