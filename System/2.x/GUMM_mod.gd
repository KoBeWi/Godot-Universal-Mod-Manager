extends Reference

var resource_storage = []
var base_path = ""

func initialize(mod_path, scene_tree):
	base_path = mod_path
	_initialize(scene_tree)

func _initialize(scene_tree):
	pass

func replace_resource_at(target_path, resource):
	resource.take_over_path(target_path)
	resource_storage.append(resource)

func load_texture(path, flags = 7):
	var image = Image()
	image.load(get_full_path(path))
	
	var texture = ImageTexture.new()
	texture.create_from_image(image, flags)
	
	return texture

func load_resource(path):
	return load(get_full_path(path))

func get_full_path(path):
	return base_path.plus_file(path.replace("mod://", ""))
