@tool
class_name AutoExportVersion
extends EditorPlugin

## Edit the "res://addons/AutoExportVersion/AutoExportVersion.gd" script to configure the plugin.
## The most important thing is the get_version() method.

####################################################################################################

## Change the code of this method to return a String that will identify your version.           [br]
## You can use the arguments to customize your version, for example based on selected platform. [br]
## Several utility methods are provided for the most common use cases. You can simply uncomment one
## of the lines in this method or combine them in any way.
func get_version(features: PackedStringArray, is_debug: bool, path: String, flags: int) -> String:
	var version: String = ""
	
#	version += get_git_commit_count()
#	version += get_git_branch_name()
#	version += get_git_commit_hash()
	version += get_git_tag()
#	version += get_export_preset_version()
#	version += get_export_preset_android_version_code() + " " + get_export_preset_android_version_name()
	
	return version


####################################################################################################


## Locations where the version can be stored See [member STORE_LOCATION]
enum VersionStoreLocation {
	SCRIPT, 
	PROJECT_SETTING,
}

## Determines where the version is saved when exporting. See [member VersionStoreLocation].                                       [br]
##  VersionStoreLocation.SCRIPT will store the version in script in path from [member SCRIPT_PATH]
const STORE_LOCATION: VersionStoreLocation = VersionStoreLocation.SCRIPT

## Path to the version script file where it is going to be saved. See [member SCRIPT_TEMPLATE]
const SCRIPT_PATH: String = "res://version.gd"
## This template String is going to be formatted so that it contains the version.
const SCRIPT_TEMPLATE: String ="extends RefCounted\nconst VERSION: String = \"{version}\""
## Name of the project setting where the version is going to be stored as a String.
const PROJECT_SETTING_NAME: String = "application/config/AutoExport/version"


####################################################################################################
####################################################################################################


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

## TODO
func get_git_tag() -> String:
	var output: Array = []
	OS.execute("git", PackedStringArray(["tag", "--sort=-v:refname"]), output)
	if output.is_empty() or output[0].is_empty():
		push_error("Failed to fetch version. Make sure you have git installed and project is inside a valid git directory.")
		return ""
	return output[0].split("\n")[0]

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

## Stores a [param version] based on [param version_store_location].                            [br]
## See [member PROJECT_SETTING_NAME], [member SCRIPT_PATH]
func store_version(version: String, version_store_location := VersionStoreLocation.PROJECT_SETTING) -> void:
	match version_store_location:
		VersionStoreLocation.SCRIPT:
			store_version_as_script(version)
		VersionStoreLocation.PROJECT_SETTING:
			store_version_as_project_setting(version)

## Stores the version as a script based on [member SCRIPT_TEMPLATE] in [member SCRIPT_PATH].
func store_version_as_script(version: String) -> void:
	if version.is_empty():
		printerr("Cannot store version. " + _EMPTY_VERSION_ERROR.format({"script_path": get_script().get_path()}))
		return
	
	var script: GDScript = GDScript.new()
	script.source_code = SCRIPT_TEMPLATE.format({"version": version})
	var err: int = ResourceSaver.save(script, SCRIPT_PATH)
	if err:
		push_error("Failed to save version as script. Error: %s" % error_string(err))

## Stores the version in ProjectSettings.                                                       [br]
## If the [param persistent] is true, then it is going to be written to the project.godot as well.
func store_version_as_project_setting(version: String, persistent := false) -> void:
	if version.is_empty():
		printerr("Cannot store version. " + _EMPTY_VERSION_ERROR.format({"script_path": get_script().get_path()}))
		return
	
	ProjectSettings.set_setting(PROJECT_SETTING_NAME, version)
	if persistent:
		ProjectSettings.save()
		ProjectSettings.set_initial_value(PROJECT_SETTING_NAME, "Empty version")
		ProjectSettings.add_property_info({
			"name": PROJECT_SETTING_NAME,
			"type": TYPE_STRING,
			"hint": PROPERTY_HINT_PLACEHOLDER_TEXT,
			"hint_string": "Will overriden on export by AutoExportVersion plugin"
		})



####################################################################################################
#################################  Unimportant plugin stuff here  ##################################
####################################################################################################


const _CURRENT_VERSION: String = "Current version: {version}"
const _EMPTY_VERSION_ERROR: String = "Version string is empty.\nMake sure your 'get_version()' in '{script_path}' is configured properly."

const _TOOL_MENU_ITEM_NAME: String = "AutoExport: Print Current Version"
const _TOOL_MENU_ITEM2_NAME: String = "AutoExport: Force-Update Version File"

var _exporter: AutoExportVersionExporter


func _enter_tree() -> void:
	_exporter = AutoExportVersionExporter.new()
	_exporter.plugin = self
	add_export_plugin(_exporter)
	add_tool_menu_item(_TOOL_MENU_ITEM_NAME, _tool_menu_print_version)
	add_tool_menu_item(_TOOL_MENU_ITEM2_NAME, func():
		var version: String = get_version([], true, "", 0)
		store_version(version, STORE_LOCATION))
	
	if STORE_LOCATION == VersionStoreLocation.SCRIPT and not FileAccess.file_exists(SCRIPT_PATH):
		store_version_as_script(get_version(PackedStringArray(), true, "", 0))

func _exit_tree() -> void:
	remove_export_plugin(_exporter)
	remove_tool_menu_item(_TOOL_MENU_ITEM_NAME)

func _tool_menu_print_version() -> void:
	var version: String = get_version(PackedStringArray(), true, "", 0)
	
	if version.is_empty():
		printerr(_EMPTY_VERSION_ERROR.format({"script_path": get_script().get_path()}))
		OS.alert(_EMPTY_VERSION_ERROR.format({"script_path": get_script().get_path()}))
		return
	
	print(_CURRENT_VERSION.format({"version":version}))
	OS.alert(_CURRENT_VERSION.format({"version":version}))


class AutoExportVersionExporter extends EditorExportPlugin:
	var plugin: EditorPlugin
	
	func _export_begin(features: PackedStringArray, is_debug: bool, path: String, flags: int) -> void:
		if not plugin:
			push_error("No plugin set in AutoExportVersionExporter")
			return
		
		var version: String = plugin.get_version(features, is_debug, path, flags)
		plugin.store_version(version, plugin.STORE_LOCATION)
