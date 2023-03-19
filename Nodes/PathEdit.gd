extends HBoxContainer

@onready var line_edit: LineEdit = $LineEdit
@onready var button: Button = $Button
@onready var file_dialog: FileDialog = $FileDialog

@export_enum("Folder", "File") var mode: int

var text: String:
	set(v):
		line_edit.text = v
	get:
		return line_edit.text

var disabled: bool:
	set(v):
		disabled = v
		line_edit.editable = not v
		button.disabled = v

signal text_changed

func _ready() -> void:
	if mode == 0:
		file_dialog.file_mode = FileDialog.FILE_MODE_OPEN_DIR
		file_dialog.dir_selected.connect(dialog_select)
	elif mode == 1:
		file_dialog.filters = Array(Registry.ICON_FORMATS).map(func(ext: String): return "*." + ext)
		file_dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
		file_dialog.file_selected.connect(dialog_select)

func line_edit_text_changed():
	text_changed.emit()

func browse() -> void:
	file_dialog.popup_centered_ratio(0.4)

func dialog_select(path: String):
	line_edit.text = path
	text_changed.emit()

func clear():
	line_edit.clear()
