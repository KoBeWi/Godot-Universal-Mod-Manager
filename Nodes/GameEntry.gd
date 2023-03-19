extends PanelContainer

@onready var button: Button = $Button

var metadata: Registry.GameData
var entry: GameDescriptor

func set_game(meta: Registry.GameData):
	metadata = meta
	
	entry = GameDescriptor.new()
	entry.load_data(metadata.entry_path)
	
	%Title.text = entry.title
	
	var image := Image.load_from_file(metadata.entry_path.path_join("icon.png"))
	%Icon.texture = ImageTexture.create_from_image(image)
	
	%Installed.text %= metadata.installed_mods.size()
	if metadata.mods_enabled:
		%Active.text %= metadata.installed_mods.filter(func(mod): return mod.active).size()
	else:
		%Active.text %= 0
