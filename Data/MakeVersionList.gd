@tool
extends EditorScript

func _run() -> void:
	var versions: Array = DirAccess.get_directories_at("res://System")
	versions.sort_custom(func(a: String, b: String) -> bool:
		var num_a: String
		for c in a:
			if c.is_valid_int():
				num_a += c
			elif c == "x":
				num_a += "0"
		
		var num_b: String
		for c in b:
			if c.is_valid_int():
				num_b += c
			elif c == "x":
				num_b += "0"
		
		return num_a.to_int() > num_b.to_int()
	)
	
	var version_file := FileAccess.open("res://System/Versions.dat", FileAccess.WRITE)
	version_file.store_line(var_to_str(versions))
