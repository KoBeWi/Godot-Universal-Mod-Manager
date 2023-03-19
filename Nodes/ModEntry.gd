extends PanelContainer

var entry: ModDescriptor
var metadata: Registry.GameData.ModData

var missing: bool
var has_icon: bool

func set_mod(meta: Registry.GameData.ModData):
	metadata = meta
	
	entry = ModDescriptor.new()
	if not entry.load_data(metadata.load_path.path_join("mod.cfg")):
		missing = true
		%Name.text = "MISSING"
		%Name.modulate = Color.RED
		%Description.text = "Mod not found at path: %s." % metadata.load_path
		%Active.disabled = true
		%Edit.disabled = true
		return
	
	%Name.text = entry.name
	%Description.text = entry.description
	%Version.text = "v.%s" % entry.version
	%Active.set_pressed_no_signal(metadata.active)
	
	%OpenFolder.pressed.connect(OS.shell_open.bind(metadata.load_path))
	
	if FileAccess.file_exists(metadata.load_path.path_join("icon.png")):
		var image := Image.load_from_file(metadata.load_path.path_join("icon.png"))
		if image:
			%Icon.texture = ImageTexture.create_from_image(image)
			has_icon = true

func toggle_active(button_pressed: bool) -> void:
	metadata.active = button_pressed
	owner.apply_mods()
