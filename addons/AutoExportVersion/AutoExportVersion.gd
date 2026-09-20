@tool
extends "ExtendedEditorPlugin.gd"

## Edit "addons/AutoExportVersion" project settings to configure the plugin
## and create version config file.

####################################################################################################


## Locations where the version can be stored See [member STORE_LOCATION].
enum VersionStoreLocation {
	## Store the version in script at path from [member SCRIPT_PATH].
	SCRIPT, 
	## Store the version in project setting [member PROJECT_SETTING_NAME].
	PROJECT_SETTING,
}

## Determines where the version is saved when exporting. See [member VersionStoreLocation].                                       [br]
var STORE_LOCATION: VersionStoreLocation = VersionStoreLocation.PROJECT_SETTING

## Path to the version script file where it is going to be saved. See [member SCRIPT_TEMPLATE]
var SCRIPT_PATH: String = "res://version.gd"
## This template String is going to be formatted so that it contains the version.
const SCRIPT_TEMPLATE: String ="extends RefCounted\nconst VERSION: String = \"{version}\""
## Name of the project setting where the version is going to be stored as a String.
var PROJECT_SETTING_NAME: String = "application/config/version"
## Path to the configuration file for the plugin.
var CONFIG_PATH = "res://auto_export_version_config_file.gd"


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

## Stores the version in ProjectSettings.
func store_version_as_project_setting(version: String) -> void:
	if version.is_empty():
		printerr("Cannot store version. " + _EMPTY_VERSION_ERROR.format({"script_path": get_script().get_path()}))
		return
	
	if not ProjectSettings.has_setting(PROJECT_SETTING_NAME):
		ProjectSettings.set_initial_value(PROJECT_SETTING_NAME, "Empty version")
		ProjectSettings.add_property_info({
			"name": PROJECT_SETTING_NAME,
			"type": TYPE_STRING,
			"hint": PROPERTY_HINT_PLACEHOLDER_TEXT,
			"hint_string": "Will overriden on export by AutoExportVersion plugin"
		})
	
	if ProjectSettings.get_setting(PROJECT_SETTING_NAME) != version:
		ProjectSettings.set_setting(PROJECT_SETTING_NAME, version)
		ProjectSettings.save()


var _CURRENT_VERSION: String
var _EMPTY_VERSION_ERROR: String
var _TOOL_MENU_ITEM_NAME: String

var _exporter: AutoExportVersionExporter

func _init() -> void:
	add_plugin_translations_from_directory("res://addons/AutoExportVersion/Translations")

func _enter_tree() -> void:
	_CURRENT_VERSION = tr_extract.tr("Current version: {version}")
	_EMPTY_VERSION_ERROR = tr_extract.tr("Version string is empty.\nMake sure your 'get_version()' in '{script_path}' is configured properly.")
	_TOOL_MENU_ITEM_NAME = tr_extract.tr("AutoExportVersion: Print and Update Current Version")
	
	_exporter = AutoExportVersionExporter.new()
	_exporter.plugin = self
	add_export_plugin(_exporter)
	add_tool_menu_item(_TOOL_MENU_ITEM_NAME, _tool_menu_print_version)
	EditorInterface.get_command_palette().add_command(_TOOL_MENU_ITEM_NAME, "auto_export_version/print_and_update", _tool_menu_print_version)
	
	STORE_LOCATION = define_project_setting("addons/AutoExportVersion/version_store_location", STORE_LOCATION, PROPERTY_HINT_ENUM, "Script,Project Setting")
	SCRIPT_PATH = define_project_setting("addons/AutoExportVersion/version_file_path", SCRIPT_PATH, PROPERTY_HINT_SAVE_FILE)
	PROJECT_SETTING_NAME = define_project_setting("addons/AutoExportVersion/version_setting_name", PROJECT_SETTING_NAME)
	CONFIG_PATH = define_project_setting("addons/AutoExportVersion/version_config_file", CONFIG_PATH, PROPERTY_HINT_SAVE_FILE)
	
	if not FileAccess.file_exists(CONFIG_PATH):
		DirAccess.copy_absolute("res://addons/AutoExportVersion/auto_export_version_config_file.gd", CONFIG_PATH)
	
	_sync_project_settings()
	ProjectSettings.settings_changed.connect(_sync_project_settings)
	
	if STORE_LOCATION == VersionStoreLocation.SCRIPT and not FileAccess.file_exists(SCRIPT_PATH):
		store_version_as_script(get_version(PackedStringArray(), true, "", 0))

func _sync_project_settings():
	STORE_LOCATION = ProjectSettings.get_setting("addons/AutoExportVersion/version_store_location")
	SCRIPT_PATH = ProjectSettings.get_setting("addons/AutoExportVersion/version_file_path")
	PROJECT_SETTING_NAME = ProjectSettings.get_setting("addons/AutoExportVersion/version_setting_name")
	
	var new_config_path: String = ProjectSettings.get_setting("addons/AutoExportVersion/version_config_file")
	if new_config_path != CONFIG_PATH:
		if FileAccess.file_exists(CONFIG_PATH) and not FileAccess.file_exists(new_config_path):
			var cached: Script = ResourceLoader.get_cached_ref(CONFIG_PATH)
			if cached:
				cached.take_over_path(new_config_path)
			
			DirAccess.rename_absolute(CONFIG_PATH, new_config_path)
			DirAccess.rename_absolute(CONFIG_PATH + ".uid", new_config_path + ".uid")
			EditorInterface.get_resource_filesystem().update_file(CONFIG_PATH)
			EditorInterface.get_resource_filesystem().update_file(new_config_path)
		
		CONFIG_PATH = new_config_path

func _exit_tree() -> void:
	remove_export_plugin(_exporter)
	remove_tool_menu_item(_TOOL_MENU_ITEM_NAME)

func _tool_menu_print_version() -> void:
	var version: String = get_version(PackedStringArray(), true, "", 0)
	
	if version.is_empty():
		EditorInterface.get_editor_toaster().push_toast(tr(_EMPTY_VERSION_ERROR).format({ "script_path": get_script().get_path() }), EditorToaster.SEVERITY_ERROR)
		OS.alert(tr(_EMPTY_VERSION_ERROR).format({ "script_path": get_script().get_path() }))
		return
	
	EditorInterface.get_editor_toaster().push_toast(tr(_CURRENT_VERSION).format({ "version": version }), EditorToaster.SEVERITY_INFO)
	OS.alert(tr(_CURRENT_VERSION).format({ "version": version }))
	store_version(version, STORE_LOCATION)

func get_version(features: PackedStringArray, is_debug: bool, path: String, flags: int) -> String:
	if not ResourceLoader.exists(CONFIG_PATH, "GDScript"):
		push_error("Version config file does not exist!")
		return ""
	
	var provider: RefCounted = load(CONFIG_PATH).new()
	return provider.get_version(features, is_debug, path, flags)

class AutoExportVersionExporter extends EditorExportPlugin:
	var plugin: EditorPlugin
	
	func _get_name() -> String:
		return "Auto Export Version"

	func _export_begin(features: PackedStringArray, is_debug: bool, path: String, flags: int) -> void:
		assert(plugin, "No plugin set in AutoExportVersionExporter")
		
		var version: String = plugin.get_version(features, is_debug, path, flags)
		plugin.store_version(version, plugin.STORE_LOCATION)
