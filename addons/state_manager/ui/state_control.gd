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

var _connection_control
var _connections: Array

var _grab := false

var _mouse_position := Vector2.ZERO
var _offset := Vector2.ZERO

func _ready() -> void:
	tag_line_edit = $MarginContainer/LineEdit
	_connection_control = $CenterContainer/Control
	
	#tag_line_edit.text_changed.connect(func (text))

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			_offset = position-get_global_mouse_position()
			_grab = event.pressed
			#if not _grab:
	if event is InputEventMouseMotion:
		if _grab:
			position = get_global_mouse_position()+_offset
			position_changed.emit(position)
	if event is InputEventKey:
		if event.keycode == KEY_DELETE and event.pressed:
			accept_event()
			deleted.emit()
			queue_free()

func add_connection(connection) -> void:
	var vbox = VBoxContainer.new()
	_connection_control.add_child(vbox)
	vbox.pivot_offset.y = 5
	vbox.position.y = -5
	
	_connections.append(connection)
#func _process(delta: float) -> void:
	#var _graph = get_tree().get_nodes_in_group("graph")[0] if not get_tree().get_nodes_in_group("graph").is_empty() else null
	#if _graph != null:
