@tool
extends "graph_element.gd"

var _dir_texture: TextureRect = null
var _panel: Panel = null

var _line_width: float = 5
var pos_from: Vector2 = Vector2.ZERO :
	set(val):
		pos_from = val
var pos_to: Vector2 = Vector2(100,0) :
	set(val):
		pos_to = val

func _ready() -> void:
	_dir_texture = $CenterContainer/TextureRect
	_panel = $MarginContainer/Panel
	
	pivot_offset.y = _line_width*0.5
	
	focus_entered.connect(func ():
		var panel_theme: StyleBoxFlat = _panel.get("theme_override_styles/panel")
		panel_theme.bg_color = Color("afcaf8")
		panel_theme.shadow_color = Color("6495ed")
	)
	focus_exited.connect(func ():
		var panel_theme: StyleBoxFlat = _panel.get("theme_override_styles/panel")
		panel_theme.bg_color = Color.WHITE
		panel_theme.shadow_color = Color.WHITE
	)
func _process(delta: float) -> void:
	var lds = pos_from.distance_to(pos_to)
	position = pos_from-pivot_offset
	size = Vector2(lds, _line_width)
	
	rotation = pos_from.angle_to_point(pos_to)
