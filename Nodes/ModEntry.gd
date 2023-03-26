extends PanelContainer

var entry: ModDescriptor
var metadata: Registry.GameData.ModData

var missing: bool
var has_icon: bool

func set_mod(meta: Registry.GameData.ModData):
	metadata = meta
	
	entry = ModDescriptor.new()
	if not entry.load_data(metadata.load_path):
		missing = true
		%Name.text = "MISSING"
		%Name.modulate = Color.RED
		%Description.text = "Mod not found at path: %s." % metadata.load_path
		%Active.disabled = true
		%Edit.disabled = true
		%OpenFolder.pressed.connect($FileDialog.popup_centered_ratio.bind(0.4))
		return
	
	%Name.text = entry.name
	%Description.text = entry.description
	%Version.text = "v.%s" % entry.version
	%Active.set_pressed_no_signal(metadata.active)
	
	%OpenFolder.pressed.connect(OS.shell_open.bind(ProjectSettings.globalize_path(metadata.load_path)))
	
	if FileAccess.file_exists(metadata.load_path.path_join("icon.png")):
		var image := Image.load_from_file(metadata.load_path.path_join("icon.png"))
		if image:
			%Icon.texture = ImageTexture.create_from_image(image)
			has_icon = true

func toggle_active(button_pressed: bool) -> void:
	metadata.active = button_pressed
	owner.apply_mods()

func try_recover(dir: String) -> void:
	if dir.is_empty():
		shoot_error.call_deferred("Path can't be empty.")
		return
	
	if not DirAccess.dir_exists_absolute(dir):
		shoot_error.call_deferred("The provided directory does not exist.")
		return
	
	if not FileAccess.file_exists(dir.path_join("mod.cfg")):
		shoot_error.call_deferred("No \"mod.cfg\" found at the given location.")
		return
	
	metadata.load_path = dir
	Registry.save_game_entry_list()
	
	owner.refresh_entry(self)

func shoot_error(error: String):
	$AcceptDialog.dialog_text = error
	$AcceptDialog.popup_centered()
