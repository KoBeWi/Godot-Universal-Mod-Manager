extends Control

var game_data: RefCounted
var game_metadata: Dictionary

var new_mod_path: String

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

func create_mod() -> void:
	%NewModDialog1.popup_centered()

func new_mod_dir_selected(dir: String) -> void:
	new_mod_path = dir
	%NewModName.clear()
	%NewModDescription.clear()
	%NewModeVersion.clear()
	%NewModDialog2.popup_centered()

func create_mod_confirmed() -> void:
	var mod_data := preload("res://Data/ModDescriptor.gd").new()
	mod_data.game = game_data.title
	mod_data.name = %NewModName.text
	mod_data.description = %NewModDescription.text
	mod_data.version = %NewModeVersion.text
	mod_data.save_data(new_mod_path)

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
		
		config.save(override_file)
	else:
		config.load(override_file)
		
		var deleted: bool
		if config.get_sections().size() == 1:
			match game_data.godot_version:
					"3.x":
						if config.get_section_keys("application").size() == 1:
							DirAccess.remove_absolute(override_file)
							deleted = true
		
		if not deleted:
			match game_data.godot_version:
				"3.x":
					config.erase_section_key("application", "run/main_scene")
			config.save(override_file)
		
		DirAccess.remove_absolute(game_metadata.game_path.path_join("GUMM_mod_loader.tscn"))

func go_back() -> void:
	get_tree().change_scene_to_file("res://Scenes/Main.tscn")
