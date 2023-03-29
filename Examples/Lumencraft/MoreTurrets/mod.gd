extends "GUMM_mod.gd"

func _initialize(scene_tree):
	# Game-specific code.
	Const.Buildings["Flamethrower Turret"].category = "Defense"
	Const.Buildings["Missile Turret"].category = "Defense"


	var file = File.new()
	if not file.file_exists("res://Nodes/mod_was_here.txt"):
		var dir = Directory.new()
		dir.open(".");
		dir.make_dir_recursive("Nodes/Buildings/_Common/Masks")

		# CFG files are not resources, so they need to be copied manually.
		# They will appear relatively to the executable and Godot can load them normally.
		dir.copy("res://Nodes/Buildings/_Common/Masks/BombTurretPhoto.png.cfg", "Nodes/Buildings/_Common/Masks/TurretRocketLauncher.png.cfg")
		dir.copy("res://Nodes/Buildings/_Common/Masks/BombTurretPhoto.png.cfg", "Nodes/Buildings/_Common/Masks/TurretFlamer.png.cfg")

		file.open("res://Nodes/mod_was_here.txt", File.WRITE) # Little trick to ensure this runs only once.
	
	replace_resource_at("res://Nodes/Buildings/Icons/BuildMenu/Missile Turret.png", load("res://Nodes/Buildings/Icons/BuildMenu/Bomb Turret.png"))
	replace_resource_at("res://Nodes/Buildings/Icons/BuildMenu/Flamethrower Turret.png", load("res://Nodes/Buildings/Icons/BuildMenu/Bomb Turret.png"))
