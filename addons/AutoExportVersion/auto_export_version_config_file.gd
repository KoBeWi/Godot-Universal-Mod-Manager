extends "res://addons/AutoExportVersion/VersionProvider.gd"

func get_version(features: PackedStringArray, is_debug: bool, path: String, flags: int) -> String:
	var version: String = ""
	
#	version += get_git_commit_count()
#	version += get_git_commit_ahead_branch_count("main")
#	version += get_git_branch_name()
#	version += get_git_commit_hash()
#	version += get_export_preset_version()
#	version += get_export_preset_android_version_code() + " " + get_export_preset_android_version_name()
	
	return version
