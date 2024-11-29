@tool
extends Control

var tag := ""

var _button: Button = null
var _line_width: float = 5
var pos_from: Vector2 = Vector2.ZERO :
	set(val):
		pos_from = val
		queue_redraw()
		_update_button_pos()
var pos_to: Vector2 = Vector2(100,100) :
	set(val):
		pos_to = val
		queue_redraw()
		_update_button_pos()

func _ready() -> void:
	_button = $Button
func _draw() -> void:
	draw_polyline([pos_from,pos_to], Color.WHITE, _line_width)
func _update_button_pos() -> void:
	var _offset = Vector2(_line_width*2,_line_width*2)
	_button.position = pos_from.lerp(pos_to, 0.5)-_offset
	_button.rotation = pos_from.angle_to_point(pos_to)#Transform2D(0,pos_from).looking_at(pos_to).get_rotation()
