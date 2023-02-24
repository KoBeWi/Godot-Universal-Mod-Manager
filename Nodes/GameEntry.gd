extends PanelContainer

@onready var button: Button = $Button

var entry: RefCounted

func set_game(entry_path: String):
	entry = preload("res://Data/GameDescriptor.gd").new()
	entry.load_data(entry_path)
	
	%Title.text = entry.title
	
	var image := Image.load_from_file(entry_path.path_join("icon.png"))
	%Icon.texture = ImageTexture.create_from_image(image)
