extends RefCounted

## Change the code of this method to return a String that will identify your version.           [br]
## You can use the arguments to customize your version, for example based on selected platform. [br]
## Several utility methods are provided for the most common use cases. You can simply uncomment one
## of the lines in this method or combine them in any way.
func get_version(features: PackedStringArray, is_debug: bool, path: String, flags: int) -> String:
	return ""

## Name of the current git branch                                                               [br]
## Useful for versions like 'master-1.0.0'                                                      [br]
## !!! Requires git installed and project inside of a git repository.
func get_git_branch_name() -> String:
	var output: Array = []
	OS.execute("git", PackedStringArray(["rev-parse", "--abbrev-ref", "HEAD"]), output)
	if output.is_empty() or output[0].is_empty():
		push_error("Failed to fetch version. Make sure you have git installed and project is inside a valid git directory.")
		return ""
	return output[0].trim_suffix("\n")

## Hash of the current git commit                                                               [br]
## Based on the [param length] you can get either full or shortened hash.                       [br]
## Useful for versions like '1.0.0-[24386f9]'                                                   [br]
## !!! Requires git installed and project inside of a git repository.
func get_git_commit_hash(length: int=7) -> String:
	var output: Array = []
	OS.execute("git", PackedStringArray(["rev-parse", "HEAD"]), output)
	if output.is_empty() or output[0].is_empty():
		push_error("Failed to fetch version. Make sure you have git installed and project is inside a valid git directory.")
		return ""
	return output[0].trim_suffix("\n").substr(0, length)

## Number of git commits                                                                        [br]
## Useful for versions like 'v.463'                                                         [br]
## !!! Requires git installed and project inside of a git repository.
func get_git_commit_count() -> String:
	var output: Array = []
	OS.execute("git", PackedStringArray(["rev-list", "--count", "HEAD"]), output)
	if output.is_empty() or output[0].is_empty():
		push_error("Failed to fetch version. Make sure you have git installed and project is inside a valid git directory.")
		return ""
	return output[0].trim_suffix("\n")

## Number of git commits ahead branch                                                           [br]
## Useful for versions like '1.6.4'                                                             [br]
## Recommended to use in combo get_git_branch_name() + "." + get_git_commit_ahead_branch_count(main), when branch name is like '1.6' [br]
## !!! Requires git installed and project inside of a git repository.
func get_git_commit_ahead_branch_count(branch_name: String) -> String:
	var output: Array = []
	OS.execute("git", PackedStringArray(["rev-list", "--count", "HEAD", "^" + branch_name]), output)
	if output.is_empty() or output[0].is_empty():
		push_error("Failed to fetch version. Make sure you have git installed and project is inside a valid git directory.")
		return "0"
	return output[0].trim_suffix("\n")

## Version from an export profile                                                               [br]
## The version will be the first non-empty version value from the first profile with that value.[br]
## Useful for versions like '1.0.0'                                                             [br]
## !!! Requires export_presets.cfg to exist.
func get_export_preset_version() -> String:
	const version_keys: Array[String] = [
		"file_version", # Windows
		"product_version", # Windows
		"version/name", # Android
		"version/code", # Android
		"application/short_version", # Mac/iOS
		"application/version", # Mac/iOS
	]
	
	var config: ConfigFile = ConfigFile.new()
	var err: int = config.load("res://export_presets.cfg")
	if err != OK:
		push_error("Cannot open 'res://export_presets.cfg'. Error: %s" % error_string(err))
		return ""
	
	for section in config.get_sections():
		if not section.ends_with(".options"):
			continue
		for key in config.get_section_keys(section):
			for check_key in version_keys:
				if key.ends_with(check_key):
					var version: String =  str(config.get_value(section, key))
					if version.is_empty():
						continue 
					return version
	
	push_error("Failed to fetch version. No valid version key found in export profiles.")
	return ""

## Version name from an android export profile                                                  [br]
## Useful for versions like '1.0.0'                                                             [br]
## !!! Requires export_presets.cfg to exist.
func get_export_preset_android_version_name() -> String:
	var config: ConfigFile = ConfigFile.new()
	var err: int = config.load("res://export_presets.cfg")
	if err != OK:
		push_error("Cannot open 'res://export_presets.cfg'. Error: %s" % error_string(err))
		return ""
	
	var version_name: String = ""
	
	for section in config.get_sections():
		if not section.ends_with(".options"):
			continue
		version_name = str(config.get_value(section, "version/name", ""))
		if not version_name.is_empty():
			return version_name
	
	push_error("Failed to fetch version name. version/name in android preset is empty")
	return ""

## Version code from an android export profile                                                  [br]
## Useful for versions like '1.0.0-1'                                                           [br]
## !!! Requires export_presets.cfg to exist.
func get_export_preset_android_version_code() -> String:
	var config: ConfigFile = ConfigFile.new()
	var err: int = config.load("res://export_presets.cfg")
	if err != OK:
		push_error("Cannot open 'res://export_presets.cfg'. Error: %s" % error_string(err))
		return ""
	
	var version_code: String = ""
	
	for section in config.get_sections():
		if not section.ends_with(".options"):
			continue
		version_code = str(config.get_value(section, "version/code", ""))
		if not version_code.is_empty():
			return version_code
	
	push_error("Failed to fetch version code. version/code in android preset is empty")
	return ""

func get_git_tag() -> String:
	var output: Array = []
	OS.execute("git", PackedStringArray(["tag", "--sort=-v:refname"]), output)
	if output.is_empty() or output[0].is_empty():
		push_error("Failed to fetch version. Make sure you have git installed and project is inside a valid git directory.")
		return ""
	return output[0].split("\n")[0]
