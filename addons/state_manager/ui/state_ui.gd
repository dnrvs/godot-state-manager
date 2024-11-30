@tool
extends Control

enum AddMode {
	STATE,
	CONNECTION
}
var _add_mode: AddMode = AddMode.STATE

var _statemachine: StateMachine

var _state_control = preload("res://addons/state_manager/ui/state_control.tscn")
var _state_connection_control = preload("res://addons/state_manager/ui/state_connection_control.tscn")
var _vbox_connection = preload("res://addons/state_manager/ui/vbox_connection.tscn")

var _graph: Control = null
var _add_option: VBoxContainer = null
var _scroll_graph: ScrollContainer = null

var _current_hovered_state = null
var _current_added_conection = null

var _drag := false

var _connections_tags = []

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
	"""
	var _add_button_fn = func (_element: PanelContainer): 
		_graph.add_child(_element)
		_element.position = get_local_mouse_position()
		_element.size = Vector2.ZERO
	_add_option.get_node("AddStateButton").pressed.connect(func ():
		var _new_state_control: PanelContainer = _state_control.instantiate()
		_graph.add_child(_new_state_control)
		_new_state_control.position = get_local_mouse_position()
		_new_state_control.size = Vector2.ZERO
		print("NEW")
	)
	"""
	
	#get_tree().get_nodes_in_group("start_state_control")[0].type = get_tree().get_nodes_in_group("start_state_control")[0].Type.START
	#get_tree().get_nodes_in_group("end_state_control")[0].type = get_tree().get_nodes_in_group("end_state_control")[0].Type.END
	
	#for state in statemachine.get_states():
	#	_add_element(state, statemachine._get_ui_states_positions()[state.tag])

#func _process(delta: float) -> void: print(get_viewport().gui_get_focus_owner())

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_MIDDLE: _drag = event.pressed# and _is_mouse_entered
		if event.button_index == MOUSE_BUTTON_RIGHT and event.pressed: 
			match _add_mode:
				AddMode.STATE: _add_new_state()
				AddMode.CONNECTION: _add_new_connection()
			#_add_option.visible = !_add_option.visible
			#_add_option.position = get_local_mouse_position()
		#if event.button_index == MOUSE_BUTTON_LEFT and event.pressed: _add_option.visible = false
	if event is InputEventMouseMotion:
		if _drag:
			var _sc = (event as InputEventMouseMotion).screen_relative
			_scroll_graph.scroll_horizontal -= _sc.x
			_scroll_graph.scroll_vertical -= _sc.y
func _add_new_state() -> void:
	var state := NState.new()
	var state_name := _statemachine._generic_name()
	_statemachine.add_state(state_name, state, _graph.get_local_mouse_position())
	_add_state(state_name)

func _add_connection(from: String, to: String, connection_ctrl = null) -> void:
	var connection_control = _state_connection_control.instantiate() if connection_ctrl == null else connection_ctrl
	if not connection_control.is_inside_tree(): 
		_graph.add_child(connection_control)
	connection_control.tag = from+">"+to
	
	var state_control_from = _get_element_control(from)
	var state_control_to = _get_element_control(to)
	
	var vbox_connection_from = _vbox_connection.instantiate()
	var vbox_connection_to = _vbox_connection.instantiate()
	_graph.add_child(vbox_connection_from)
	_graph.add_child(vbox_connection_to)
	
	_connections_tags.append({"from": from, "to": to})
	
	state_control_from.position_changed.connect(func (_v): _update_ui_connection(connection_control, state_control_from, state_control_to))
	state_control_to.position_changed.connect(func (_v): _update_ui_connection(connection_control, state_control_from, state_control_to))
	
	state_control_from.position_changed.emit(state_control_from.position)
	state_control_to.position_changed.emit(state_control_to.position)

func _add_new_connection() -> void:
	if _current_hovered_state == null: return
	
	EditorInterface.mark_scene_as_unsaved()
	
	var _element = _state_connection_control.instantiate()
	_graph.add_child(_element)
	
	
	#_element.pos_from = _current_hovered_state.position + (_current_hovered_state.size*0.5)
	#_element.pos_to = _graph.get_local_mouse_position()
	var from_state = _current_hovered_state
	var mouse_fn = func (event):
		if event is InputEventMouseMotion:
			_update_ui_connection(
				_element, from_state, 
				_graph.get_local_mouse_position() if _current_hovered_state == null else _current_hovered_state
			)
	gui_input.connect(mouse_fn)
	
	while true:
		var event = await gui_input
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and not event.pressed:
			break
	gui_input.disconnect(mouse_fn)
	
	if _current_hovered_state != null and _current_hovered_state != from_state:
		var connection = StateConnection.new()
		_statemachine.add_connection(from_state.tag, _current_hovered_state.tag, connection)
		_add_connection(from_state.tag, _current_hovered_state.tag, _element)
	else:
		_element.queue_free()
func _add_state(state_name: String) -> void:
	EditorInterface.mark_scene_as_unsaved()
	
	var _element: PanelContainer = _state_control.instantiate()
	
	_graph.add_child(_element)
	_element.tag = state_name
	var _element_panel_theme: StyleBoxFlat = _element.get("theme_override_styles/panel").duplicate()
	_element.set("theme_override_styles/panel", _element_panel_theme)
	
	_element_panel_theme.border_width_left = 1
	_element_panel_theme.border_width_top = 1
	_element_panel_theme.border_width_right = 1
	_element_panel_theme.border_width_bottom = 1
	if state_name == "Start":
		_element_panel_theme.border_color = Color.ORANGE
	elif state_name == "End":
		_element_panel_theme.border_color = Color.CYAN
	else:
		_element_panel_theme.border_width_left = 0
		_element_panel_theme.border_width_top = 0
		_element_panel_theme.border_width_right = 0
		_element_panel_theme.border_width_bottom = 0
	
	_element.position = _statemachine._get_ui_state_position(state_name)
	_element.set_deferred("size", Vector2.ZERO)
	
	_element.tag_line_edit.text_submitted.connect(func (new_text) -> void:
		EditorInterface.mark_scene_as_unsaved()
		_statemachine.change_state_name(_element.tag, new_text)
		_element.tag = new_text
		get_viewport().gui_release_focus()
	)
	_element.position_changed.connect(func (new_pos) -> void:
		EditorInterface.mark_scene_as_unsaved()
		_statemachine._set_ui_state_position(_element.tag, new_pos)
	)
	_element.focus_entered.connect(func () -> void:
		EditorInterface.inspect_object(_statemachine.get_state(_element.tag))
	)
	_element.focus_exited.connect(func () -> void:
		EditorInterface.inspect_object(null)
	)
	_element.mouse_entered.connect(func () -> void:
		_current_hovered_state = _element
	)
	_element.mouse_exited.connect(func () -> void:
		_current_hovered_state = null
	)
	_element.deleted.connect(func () -> void:
		EditorInterface.mark_scene_as_unsaved()
		_statemachine.remove_state(_element.tag)
	)
func _get_element_control(tag: String) -> Control:
	for element in _graph.get_children():
		if "tag" in element and element.tag == tag:
			return element
	return null

func load_statemachine(statemachine: StateMachine) -> void:
	clear()
	if statemachine == null: return
	
	_statemachine = statemachine
	for state_name in _statemachine.get_states():
		_add_state(state_name)
	_graph.visible = true
	
	_scroll_graph.set_deferred("scroll_horizontal", _scroll_graph.get_h_scroll_bar().max_value*0.25)
	_scroll_graph.set_deferred("scroll_vertical", _scroll_graph.get_v_scroll_bar().max_value*0.35)
func clear() -> void:
	for element in _graph.get_children():
		element.queue_free()
	_statemachine = null
	_graph.visible = false

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
		if not connection.tag.is_empty() and _statemachine.has_connection(c_tags[1], c_tags[0]):
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
