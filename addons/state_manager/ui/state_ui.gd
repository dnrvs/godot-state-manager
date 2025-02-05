@tool
extends Control

enum Mode {
	EDIT,
	ADD,
	REMOVE
}
var _current_mode: Mode = Mode.EDIT

const ElementType = preload("res://addons/state_manager/ui/graph_element.gd").Type
var _add_mode: ElementType = ElementType.STATE
var _current_element: Control = null

var _state_machine: StateMachine

var _state_control = preload("res://addons/state_manager/ui/state_control.tscn")
var _state_connection_control = preload("res://addons/state_manager/ui/state_connection_control.tscn")

var _graph: Control = null
var _scroll_graph: ScrollContainer = null

var _alignment_panels: Array[Control]

var _drag := false

var _grab_element := false
var _offset_grab_element: Vector2

var _undo_redo: EditorUndoRedoManager

func _ready() -> void:
	_scroll_graph = $VBoxContainer/Control/ScrollContainer
	_graph = $VBoxContainer/Control/ScrollContainer/Graph
	
	_alignment_panels.append($VBoxContainer/Control/XAlignmentPanel)
	_alignment_panels.append($VBoxContainer/Control/YAlignmentPanel)
	
	$VBoxContainer/HBoxContainer/EditButton.pressed.connect(func ():
		_current_mode = Mode.EDIT
		_reset_selected_panels()
		$VBoxContainer/HBoxContainer/EditButton.get_child(0).visible = true
	)
	$VBoxContainer/HBoxContainer/AddStateButton.pressed.connect(func ():
		_current_mode = Mode.ADD
		_add_mode = ElementType.STATE
		_reset_selected_panels()
		$VBoxContainer/HBoxContainer/AddStateButton.get_child(0).visible = true
	)
	$VBoxContainer/HBoxContainer/AddConnectionButton.pressed.connect(func ():
		_current_mode = Mode.ADD
		_add_mode = ElementType.CONNECTION
		_reset_selected_panels()
		$VBoxContainer/HBoxContainer/AddConnectionButton.get_child(0).visible = true
	)

func _gui_input(event: InputEvent) -> void:
	if _current_mode == Mode.EDIT:
		if _current_element != null:
			if event is InputEventMouseButton:
				if event.button_index == MOUSE_BUTTON_LEFT:
					_grab_element = event.pressed
					_offset_grab_element = _current_element.position-get_global_mouse_position()
					if not event.pressed:
						for panel in _alignment_panels:
							panel.visible = false
						_change_state_position(_current_element.tag, _current_element.position)
			if event is InputEventMouseMotion:
				if _grab_element:
					_current_element.grab(get_global_mouse_position()+_offset_grab_element)
					
					var states = _graph.get_children().filter(func (e) -> bool: return e.type == ElementType.STATE)
					for axis in range(2):
						for element in states:
							if not _current_element == element:
								var a_pos = _current_element.global_position[axis]+(_current_element.size[axis]*0.5)
								var b_pos = element.global_position[axis]+(element.size[axis]*0.5)
								
								var distance = abs(a_pos-b_pos)
								if distance <= 5:
									_alignment_panels[axis].visible = true
									_alignment_panels[axis].global_position[axis] = b_pos-_alignment_panels[axis].size[axis]*0.5
									_current_element.position[axis] = element.position[axis]
									break
								else:
									_alignment_panels[axis].visible = false
	if _current_mode == Mode.ADD:
		if event is InputEventMouseButton:
			if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
				match _add_mode:
					ElementType.STATE:
						add_state(State.new())
					ElementType.CONNECTION:
						add_connection(StateConnection.new())
	
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_MIDDLE: 
			_drag = event.pressed
	
	if event is InputEventMouseMotion:
		if _drag:
			var _sc = (event as InputEventMouseMotion).screen_relative
			_scroll_graph.scroll_horizontal -= _sc.x
			_scroll_graph.scroll_vertical -= _sc.y

func add_state(state: State, state_name: String = "") -> void:
	_undo_redo.create_action("Add State")
	if not state_name:
		state_name = _state_machine._generic_name()
	_undo_redo.add_do_method(_state_machine, "add_state", state_name, state, _graph.get_local_mouse_position())
	_undo_redo.add_undo_method(_state_machine, "remove_state", state_name)
	_undo_redo.add_do_method(self, "_add_graph_state", state_name)
	_undo_redo.add_undo_method(self, "_remove_graph_element", state_name)
	_undo_redo.commit_action()
	EditorInterface.mark_scene_as_unsaved()
func remove_state(state_name: String):
	var state = _state_machine.get_state(state_name)
	var state_position = _state_machine._get_ui_state_position(state_name)
	
	_undo_redo.create_action("Remove State", 0, null, false)
	
	_undo_redo.add_do_method(_state_machine, "remove_state", state_name)
	_undo_redo.add_undo_method(_state_machine, "add_state", state_name, state, state_position)
	
	_undo_redo.add_do_method(self, "_remove_graph_element", state_name)
	_undo_redo.add_undo_method(self, "_add_graph_state", state_name)
	for connection in _graph.get_children().filter(func (v) -> bool: return v.type == ElementType.CONNECTION):
		if state_name in connection.tag:
			remove_connnection(connection.tag)
	_undo_redo.commit_action()
	EditorInterface.mark_scene_as_unsaved()
func _add_graph_state(state_name: String):
	var graph_state: Control
	graph_state = _state_control.instantiate()
	_add_element_to_graph(graph_state)
	graph_state.tag = state_name
	
	var state_panel_theme: StyleBoxFlat = graph_state.panel.get("theme_override_styles/panel")
	
	state_panel_theme.border_width_left = 1
	state_panel_theme.border_width_top = 1
	state_panel_theme.border_width_right = 1
	state_panel_theme.border_width_bottom = 1
	if state_name == "Start":
		state_panel_theme.border_color = Color.ORANGE
		graph_state.tag_line_edit.editable = false
		graph_state.tag_line_edit.mouse_filter = MOUSE_FILTER_IGNORE
	elif state_name == "End":
		state_panel_theme.border_color = Color.CYAN
		graph_state.tag_line_edit.editable = false
		graph_state.tag_line_edit.mouse_filter = MOUSE_FILTER_IGNORE
	else:
		state_panel_theme.border_width_left = 0
		state_panel_theme.border_width_top = 0
		state_panel_theme.border_width_right = 0
		state_panel_theme.border_width_bottom = 0
	
	graph_state.position = _state_machine._get_ui_state_position(state_name)
	graph_state.set_deferred("size", Vector2.ZERO)
	
	graph_state.tag_line_edit.text_submitted.connect(func (new_text) -> void:
		_undo_redo.create_action("State Renamed")
		
		_undo_redo.add_do_method(_state_machine, "change_state_name", graph_state.tag, new_text)
		_undo_redo.add_undo_method(_state_machine, "change_state_name", new_text, graph_state.tag)
		_undo_redo.add_do_property(graph_state, "tag", new_text)
		_undo_redo.add_undo_property(graph_state, "tag", graph_state.tag)
		
		_undo_redo.commit_action()
		EditorInterface.mark_scene_as_unsaved()
		get_viewport().gui_release_focus()
	)
	graph_state.focus_entered.connect(func () -> void:
		EditorInterface.inspect_object(_state_machine.get_state(graph_state.tag))
	)
	graph_state.removed.connect(func () -> void:
		if can_be_removed(graph_state):
			remove_state(graph_state.tag)
	)
	graph_state.tree_exiting.connect(func () -> void:
		EditorInterface.inspect_object(null)
	)
func _change_state_position(state: String, new_pos: Vector2) -> void:
	if not _state_machine.has_state(state):
		return
	var state_element = _get_graph_element(state)
	var old_pos = _state_machine._get_ui_state_position(state)
	
	_undo_redo.create_action("Moved State")
	
	_undo_redo.add_do_method(_state_machine, "_set_ui_state_position", state, new_pos)
	_undo_redo.add_undo_method(_state_machine, "_set_ui_state_position", state, old_pos)
	_undo_redo.add_do_property(state_element, "position", new_pos)
	_undo_redo.add_undo_property(state_element, "position", old_pos)
	
	_undo_redo.commit_action()
	EditorInterface.mark_scene_as_unsaved()

func add_connection(connection: StateConnection, connection_name: String = "") -> void:
	if not connection_name:
		var get_hovered_state = func ():
			var hovered_element = _get_hovered_element()
			if hovered_element == null or not _state_machine.has_state(hovered_element.tag):
				return null
			return hovered_element
		
		var from_state = get_hovered_state.call()
		if from_state == null: 
			return
		
		var pre_connection = _state_connection_control.instantiate()
		_graph.add_child(pre_connection)
		
		var mouse_fn = func (event):
			if event is InputEventMouseMotion:
				var hovered_state = get_hovered_state.call()
				_update_ui_connection(
					pre_connection, from_state, 
					_graph.get_local_mouse_position() if hovered_state == null else hovered_state
				)
		gui_input.connect(mouse_fn)
		
		while true:
			var event = await gui_input
			if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
				break
		gui_input.disconnect(mouse_fn)
		
		pre_connection.queue_free()
		
		var to_state = get_hovered_state.call()
		
		# Cancel connection if not valid
		if to_state and not _state_machine.has_connection(from_state.tag, to_state.tag) and to_state != from_state:
			connection_name = from_state.tag+">"+to_state.tag
		else:
			return
	var from: String = connection_name.get_slice(">",0)
	var to: String = connection_name.get_slice(">",1)
	
	#if not _disable_undoredo_action:
	_undo_redo.create_action("Add Connection")
	_undo_redo.add_do_method(_state_machine, "add_connection", from, to, connection)
	_undo_redo.add_undo_method(_state_machine, "remove_connection", from, to)
	_undo_redo.add_do_method(self, "_add_graph_connection", connection_name)
	_undo_redo.add_undo_method(self, "_remove_graph_element", connection_name)
	_undo_redo.commit_action()
	EditorInterface.mark_scene_as_unsaved()
func remove_connnection(connection_name: String, _disable_undoredo_action: bool = false) -> void:
	var from = connection_name.get_slice(">", 0)
	var to = connection_name.get_slice(">", 1)
	
	var connection = _state_machine.get_connection(from, to)
	
	if not _disable_undoredo_action:
		_undo_redo.create_action("Remove Connection", 0, null, true)
	
	_undo_redo.add_do_method(_state_machine, "remove_connection", from, to)
	_undo_redo.add_undo_method(_state_machine, "add_connection", from, to, connection)
	_undo_redo.add_do_method(self, "_remove_graph_element", connection_name)
	_undo_redo.add_undo_method(self, "_add_graph_connection", connection_name)
	if not _disable_undoredo_action:
		_undo_redo.commit_action()
	EditorInterface.mark_scene_as_unsaved()
func _add_graph_connection(connection_name: String) -> void:
	var from = connection_name.get_slice(">",0)
	var to = connection_name.get_slice(">",1)
	
	var graph_connection: Control
	graph_connection = _state_connection_control.instantiate()
	_add_element_to_graph(graph_connection)
	graph_connection.tag = from+">"+to
	
	var state_control_from = _get_graph_element(from)
	var state_control_to = _get_graph_element(to)
	
	var connection_mv_fn = func (_v = null) -> void: 
		_update_ui_connection(graph_connection, state_control_from, state_control_to)
	state_control_from.position_update.connect(connection_mv_fn)
	state_control_to.position_update.connect(connection_mv_fn)
	
	connection_mv_fn.call()
	
	var update_opposite_connection = func () -> void:
		var opposite_connection = _get_graph_element(state_control_to.tag+">"+state_control_from.tag)
		if opposite_connection:
			_update_ui_connection(opposite_connection, state_control_to, state_control_from)
	update_opposite_connection.call()
	
	graph_connection.focus_entered.connect(func () -> void:
		var c_tags: PackedStringArray = graph_connection.tag.split(">")
		EditorInterface.inspect_object(_state_machine.get_connection(c_tags[0],c_tags[1]))
	)
	graph_connection.removed.connect(func () -> void:
		remove_connnection(connection_name)
	)
	graph_connection.tree_exiting.connect(func () -> void:
		if _state_machine:
			var from_state = _get_graph_element(from)
			if from_state:
				from_state.position_update.disconnect(connection_mv_fn)
			var to_state = _get_graph_element(to)
			if to_state:
				to_state.position_update.disconnect(connection_mv_fn)
			if not from_state == null and not to_state == null:
				update_opposite_connection.call()
	)

func _add_element_to_graph(element: Control) -> void:
	_graph.add_child(element)
	
	element.focus_entered.connect(func () -> void:
		_current_element = element
	)
	
	element.removed.connect(func () -> void:
		if can_be_removed(element):
			element.queue_free()
	)
func _remove_graph_element(tag: String) -> void:
	var graph_element = _get_graph_element(tag)
	if not graph_element:
		return
	
	graph_element.queue_free()

func _get_graph_element(tag: String) -> Control:
	for element in _graph.get_children():
		if "tag" in element and element.tag == tag:
			return element
	return null

func can_be_removed(graph_element: Control) -> bool:
	return _state_machine.can_be_removed(graph_element.tag)

func load_state_machine(state_machine: StateMachine) -> void:
	clear()
	if state_machine == null: return
	
	_state_machine = state_machine
	
	for state in _state_machine.get_states():
		_add_graph_state(state)
	for from in _state_machine.get_states():
		for to in _state_machine.get_state_connections(from):
			_add_graph_connection(from+">"+to)
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

func _reset_selected_panels() -> void:
	var hbox_button = $VBoxContainer/HBoxContainer
	for button in hbox_button.get_children():
		button.get_child(0).visible = false

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
