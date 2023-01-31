extends VBoxContainer

var game_name: String

var new_mod_path: String

func _ready() -> void:
	%GameTitle.text = game_name

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
	mod_data.game = game_name
	mod_data.name = %NewModName.text
	mod_data.description = %NewModDescription.text
	mod_data.version = %NewModeVersion.text
	mod_data.save_data(new_mod_path)
