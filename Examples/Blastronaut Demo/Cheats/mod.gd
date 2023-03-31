extends "GUMM_mod.gd"

func _initialize(scene_tree):
	# Inject a custom node.
	var spawner = TreeStalker.new()
	spawner.gumm = self
	scene_tree.root.call_deferred("add_child", spawner)

# Our custom class that observes the scene tree for interesting nodes.
class TreeStalker extends Node:
	var gumm
	var console
	var hud
	
	func _ready():
		# Notify me on each new node.
		get_tree().connect("node_added", self, "on_new_node")
	
	func on_new_node(node):
		if not hud:
			# Find hud. This is required for infinite money.
			if node.name == "HudLayer":
				hud = node
				if console: # The hud and console are intialized in order-indepdendent way.
					console.hud = hud
		
		if not console:
			# First marker signifies that the game started.
			if node.name == "DirectionMarker":
				# Spawn our console.
				console = load(gumm.get_full_path("mod://Console.tscn")).instance()
				get_tree().root.add_child(console)

				if hud:
					console.hud = hud
			return # If the game didn't start, no point in the next check.
		
		if node.name.begins_with("BackPack"):
			# If a BackPack was spawned, it means player died. Mark it for easy retrieval.
			node.add_to_group("gumm_backpack")
	