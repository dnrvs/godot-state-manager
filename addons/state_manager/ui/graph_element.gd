@tool
extends Control

enum Type {
	STATE,
	CONNECTION
}
@export var type: Type

var main_ui: Control = null

var tag: String : set = _set_tag

func _set_tag(val) -> void:
	tag = val

func _gui_input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.keycode == KEY_DELETE and event.pressed and main_ui.can_be_removed():
			accept_event()
			queue_free()
