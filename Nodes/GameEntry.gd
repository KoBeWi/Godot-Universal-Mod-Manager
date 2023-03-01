extends PanelContainer

@onready var button: Button = $Button

var entry: GameDescriptor

func set_game(entry_path: String):
	entry = GameDescriptor.new()
	entry.load_data(entry_path)
	
	%Title.text = entry.title
	
	var image := Image.load_from_file(entry_path.path_join("icon.png"))
	%Icon.texture = ImageTexture.create_from_image(image)
