extends PanelContainer

@onready var button: Button = $Button

var entry: GameDescriptor
var metadata: Registry.GameData

var missing: bool
var has_icon: bool

func set_game(meta: Registry.GameData):
	metadata = meta
	
	entry = GameDescriptor.new()
	if not entry.load_data(metadata.entry_path):
		missing = true
		%Title.text = "MISSING"
		%Title.modulate = Color.RED
		%Installed.text = "Game info not found at path: %s." % metadata.entry_path
		%Active.hide()
		%OpenFolder.pressed.connect($FileDialog.popup_centered_ratio.bind(0.4))
		$Button.pressed.connect($FileDialog.popup_centered_ratio.bind(0.4))
		return
	
	entry.load_data(metadata.entry_path)
	
	%Title.text = entry.title
	
	var image := Image.load_from_file(metadata.entry_path.path_join("icon.png"))
	%Icon.texture = ImageTexture.create_from_image(image)
	
	%Installed.text %= metadata.installed_mods.size()
	if metadata.mods_enabled:
		%Active.text %= metadata.installed_mods.filter(func(mod): return mod.active).size()
	else:
		%Active.text %= 0
	
	%OpenFolder.pressed.connect(OS.shell_open.bind(ProjectSettings.globalize_path(metadata.entry_path)))

func try_recover(dir: String) -> void:
	if dir.is_empty():
		shoot_error.call_deferred("Path can't be empty.")
		return
	
	if not DirAccess.dir_exists_absolute(dir):
		shoot_error.call_deferred("The provided directory does not exist.")
		return
	
	if not FileAccess.file_exists(dir.path_join("game.cfg")):
		shoot_error.call_deferred("No \"game.cfg\" found at the given location.")
		return
	
	metadata.entry_path = dir
	Registry.save_game_entry_list()
	
	owner.refresh_entry(self)

func shoot_error(error: String):
	$AcceptDialog.dialog_text = error
	$AcceptDialog.popup_centered()
