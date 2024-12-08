@tool
extends PanelContainer

signal tag_changed(tag, new_tag)
signal deleted
signal position_changed(pos)

var tag_line_edit: LineEdit
var tag: String = "" :
	set(val):
		tag = val
		tag_line_edit.text = tag

var _grab := false

var _mouse_position := Vector2.ZERO
var _offset := Vector2.ZERO

func _ready() -> void:
	tag_line_edit = $MarginContainer/LineEdit

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			_offset = position-get_global_mouse_position()
			_grab = event.pressed
	if event is InputEventMouseMotion:
		if _grab:
			position = get_global_mouse_position()+_offset
			position_changed.emit(position)
