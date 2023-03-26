extends RefCounted

var resource_storage: Array[Resource]
var base_path: String

func initialize(mod_path: String, scene_tree: SceneTree) -> void:
	base_path = mod_path
	_initialize(scene_tree)

func _initialize(scene_tree: SceneTree) -> void:
	pass

func replace_resource_at(target_path: String, resource: Resource) -> void:
	resource.take_over_path(target_path)
	resource_storage.append(resource)

func load_texture(path: String) -> Texture2D:
	return ImageTexture.create_from_image(Image.load_from_file(get_full_path(path)))

func load_mp3(path: String) -> AudioStreamMP3:
	var file := FileAccess.open(path, FileAccess.READ)
	var data := file.get_buffer(file.get_length())
	
	var stream := AudioStreamMP3.new()
	stream.data = data
	
	return stream

func load_resource(path: String) -> Resource:
	return load(get_full_path(path))

func get_full_path(path: String) -> String:
	return base_path.path_join(path.trim_prefix("mod://"))
