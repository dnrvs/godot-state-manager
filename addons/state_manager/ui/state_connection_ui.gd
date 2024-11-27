@tool
extends Line2D

@export var from_pos: Vector2 :
	set(val):
		if not is_node_ready(): await ready
		from_pos = val
		set_point_position(0, from_pos)
		_update_sprite_pos()
@export var to_pos: Vector2 :
	set(val):
		if not is_node_ready(): await ready
		to_pos = val
		set_point_position(1, to_pos)
		_update_sprite_pos()

var _sprite: Sprite2D = null

func _enter_tree() -> void:
	clear_points()
	add_point(Vector2.ZERO)
	add_point(Vector2.ZERO)
	from_pos = Vector2(0,0)
	to_pos = Vector2(15, 12)

func _ready() -> void:
	_sprite = $Sprite2D

func _update_sprite_pos() -> void:
	_sprite.position = from_pos.lerp(to_pos, 0.5)
	_sprite.look_at(to_pos)
