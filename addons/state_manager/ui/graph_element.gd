@tool
extends Control

signal removed

enum Type {
	STATE,
	CONNECTION
}
@export var type: Type

var tag: String : set = _set_tag

func _set_tag(val) -> void:
	tag = val

func _gui_input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.keycode == KEY_DELETE and event.pressed:
			accept_event()
			remove()

func grab(to: Vector2) -> void: 
	pass

func remove() -> void:
	removed.emit()
