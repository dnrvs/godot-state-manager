@tool
extends Control

enum AddMode {
	STATE,
	CONNECTION
}
var _add_mode: AddMode = AddMode.STATE

var _state_machine: StateMachine

var _state_control = preload("res://addons/state_manager/ui/state_control.tscn")
var _state_connection_control = preload("res://addons/state_manager/ui/state_connection_control.tscn")
var _vbox_connection = preload("res://addons/state_manager/ui/vbox_connection.tscn")

var _graph: Control = null
var _add_option: VBoxContainer = null
var _scroll_graph: ScrollContainer = null

#var _current_hovered_state = null
#var _current_added_conection = null

var _drag := false

#var _connections_tags = []

func _ready() -> void:
	_scroll_graph = $VBoxContainer/Control/ScrollContainer
	
	_graph = $VBoxContainer/Control/ScrollContainer/Graph
	_add_option = $AddOption
	
	$VBoxContainer/HBoxContainer/AddStateButton.pressed.connect(func ():
		_add_mode = AddMode.STATE
	)
	$VBoxContainer/HBoxContainer/AddConnectionButton.pressed.connect(func ():
		_add_mode = AddMode.CONNECTION
	)

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_MIDDLE: _drag = event.pressed# and _is_mouse_entered
		if event.button_index == MOUSE_BUTTON_RIGHT and event.pressed: 
			match _add_mode:
				AddMode.STATE: _add_new_state()
				AddMode.CONNECTION: _add_new_connection()
	if event is InputEventMouseMotion:
		if _drag:
			var _sc = (event as InputEventMouseMotion).screen_relative
			_scroll_graph.scroll_horizontal -= _sc.x
			_scroll_graph.scroll_vertical -= _sc.y
	if event is InputEventKey:
		if event.keycode == KEY_DELETE and event.pressed and _get_selected_element():
			accept_event()
			_get_selected_element().queue_free()

func _add_state(state_name: String) -> void:
	var state_control: PanelContainer = _state_control.instantiate()
	
	_graph.add_child(state_control)
	state_control.tag = state_name
	var state_panel_theme: StyleBoxFlat = state_control.get("theme_override_styles/panel")
	
	state_panel_theme.border_width_left = 1
	state_panel_theme.border_width_top = 1
	state_panel_theme.border_width_right = 1
	state_panel_theme.border_width_bottom = 1
	if state_name == "Start":
		state_panel_theme.border_color = Color.ORANGE
		state_control.tag_line_edit.editable = false
		state_control.tag_line_edit.mouse_filter = MOUSE_FILTER_IGNORE
	elif state_name == "End":
		state_panel_theme.border_color = Color.CYAN
		state_control.tag_line_edit.editable = false
		state_control.tag_line_edit.mouse_filter = MOUSE_FILTER_IGNORE
	else:
		state_panel_theme.border_width_left = 0
		state_panel_theme.border_width_top = 0
		state_panel_theme.border_width_right = 0
		state_panel_theme.border_width_bottom = 0
	
	state_control.position = _state_machine._get_ui_state_position(state_name)
	state_control.set_deferred("size", Vector2.ZERO)
	
	state_control.tag_line_edit.text_submitted.connect(func (new_text) -> void:
		EditorInterface.mark_scene_as_unsaved()
		_state_machine.change_state_name(state_control.tag, new_text)
		state_control.tag = new_text
		get_viewport().gui_release_focus()
	)
	state_control.position_changed.connect(func (new_pos) -> void:
		EditorInterface.mark_scene_as_unsaved()
		_state_machine._set_ui_state_position(state_control.tag, new_pos)
	)
	state_control.focus_entered.connect(func () -> void:
		EditorInterface.inspect_object(_state_machine.get_state(state_control.tag))
	)
	state_control.focus_exited.connect(func () -> void:
		EditorInterface.inspect_object(null)
	)
	state_control.tree_exiting.connect(func () -> void:
		if _state_machine:
			EditorInterface.mark_scene_as_unsaved()
			_state_machine.remove_state(state_control.tag)
	)
func _add_new_state() -> void:
	EditorInterface.mark_scene_as_unsaved()
	
	var state := NState.new()
	var state_name := _state_machine._generic_name()
	_state_machine.add_state(state_name, state, _graph.get_local_mouse_position())
	_add_state(state_name)

func _add_connection(from: String, to: String, connection_control = null) -> void:
	if connection_control == null:
		connection_control = _state_connection_control.instantiate()
	if not connection_control.is_inside_tree(): 
		_graph.add_child(connection_control)
	connection_control.tag = from+">"+to
	
	var state_control_from = _get_element_control(from)
	var state_control_to = _get_element_control(to)
	
	var vbox_connection_from = _vbox_connection.instantiate()
	var vbox_connection_to = _vbox_connection.instantiate()
	_graph.add_child(vbox_connection_from)
	_graph.add_child(vbox_connection_to)
	
	state_control_from.position_changed.connect(func (_v): _update_ui_connection(connection_control, state_control_from, state_control_to))
	state_control_to.position_changed.connect(func (_v): _update_ui_connection(connection_control, state_control_from, state_control_to))
	
	state_control_from.position_changed.emit(state_control_from.position)
	state_control_to.position_changed.emit(state_control_to.position)
	
	connection_control.focus_entered.connect(func () -> void:
		var c_tags: PackedStringArray = connection_control.tag.split(">")
		EditorInterface.inspect_object(_state_machine.get_connection(c_tags[0],c_tags[1]))
	)
	connection_control.focus_exited.connect(func () -> void:
		EditorInterface.inspect_object(null)
	)
	connection_control.tree_exiting.connect(func () -> void:
		if _state_machine:
			EditorInterface.mark_scene_as_unsaved()
			_state_machine.remove_connection(from, to)
	)
func _add_new_connection() -> void:
	var get_hovered_state = func ():
		var hovered_element = _get_hovered_element()
		if hovered_element == null or not _state_machine.has_state(hovered_element.tag):
			return null
		return hovered_element
	
	var from_state = get_hovered_state.call()
	if from_state == null: 
		return
	
	EditorInterface.mark_scene_as_unsaved()
	
	var connection_control = _state_connection_control.instantiate()
	_graph.add_child(connection_control)
	
	var mouse_fn = func (event):
		if event is InputEventMouseMotion:
			var hovered_state = get_hovered_state.call()
			_update_ui_connection(
				connection_control, from_state, 
				_graph.get_local_mouse_position() if hovered_state == null else hovered_state
			)
	gui_input.connect(mouse_fn)
	
	while true:
		var event = await gui_input
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and not event.pressed:
			break
	gui_input.disconnect(mouse_fn)
	
	var to_state = get_hovered_state.call()
	if to_state != null and to_state != from_state:
		var connection = StateConnection.new()
		_state_machine.add_connection(from_state.tag, to_state.tag, connection)
		_add_connection(from_state.tag, to_state.tag, connection_control)
	else:
		connection_control.queue_free()

func _get_element_control(tag: String) -> Control:
	for element in _graph.get_children():
		if "tag" in element and element.tag == tag:
			return element
	return null

func load_state_machine(state_machine: StateMachine) -> void:
	clear()
	if state_machine == null: return
	
	_state_machine = state_machine
	
	for state in _state_machine.get_states():
		_add_state(state)
	for from in _state_machine.get_states():
		for to in _state_machine.get_state_connections(from):
			_add_connection.call_deferred(from, to)
	
	_graph.visible = true
	
	_scroll_graph.set_deferred("scroll_horizontal", _scroll_graph.get_h_scroll_bar().max_value*0.25)
	_scroll_graph.set_deferred("scroll_vertical", _scroll_graph.get_v_scroll_bar().max_value*0.35)
func clear() -> void:
	_state_machine = null
	for element in _graph.get_children():
		element.queue_free()
	_graph.visible = false

func _get_selected_element():
	var focused_control := get_viewport().gui_get_focus_owner()
	if focused_control == null or focused_control.get_parent() != _graph:
		return null
	return focused_control
func _get_hovered_element():
	var hovered_control := get_viewport().gui_get_hovered_control()
	if hovered_control == null or not _graph.is_ancestor_of(hovered_control):
		return null
	var graph_element = hovered_control
	while graph_element.get_parent_control() != _graph:
		graph_element = graph_element.get_parent_control()
	return graph_element

func _update_ui_connection(connection, s_from, s_to):
	if (
		connection == null or 
		not (s_from is Control or s_from is Vector2) or
		not (s_to is Control or s_to is Vector2)
	):
		return
	
	var from_v: Vector2 = (s_from.position + (s_from.size*0.5)) if s_from is Control else s_from
	var to_v: Vector2 = (s_to.position + (s_to.size*0.5)) if s_to is Control else s_to
	
	var c_tags: PackedStringArray = connection.tag.split(">")
	if not connection.tag.is_empty() and _state_machine.has_connection(c_tags[1], c_tags[0]):
		var c_angle = from_v.angle_to_point(to_v)
		var offset = Vector2.UP
		offset = offset.rotated(c_angle)
		from_v += offset*15
		to_v += offset*15
	var from_p = _find_exit_point(from_v, to_v, s_from) if s_from is Control else from_v
	var to_p = _find_exit_point(to_v, from_v, s_to) if s_to is Control else to_v
	
	if from_p == null and to_p == null:
		connection.visible = false
	else:
		connection.visible = true
		connection.pos_from = from_p
		connection.pos_to = to_p
func _find_exit_point(from: Vector2, to: Vector2, control: Control):
	var r_start = control.position
	var r_end = control.position + control.size
	
	var result = Geometry2D.intersect_polyline_with_polygon(
		[from, to], 
		[r_start, Vector2(r_end.x, r_start.y), r_end, Vector2(r_start.x, r_end.y)]
	)
	if result.is_empty():
		return null
	return result[0][1]
