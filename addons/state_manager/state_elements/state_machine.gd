@tool
extends Resource
class_name StateMachine

const StateData = preload("res://addons/state_manager/state_elements/state_data.gd")
const StateConnectionData = preload("res://addons/state_manager/state_elements/state_connection_data.gd")

var _states: Array[StateData]
var _connections: Array[StateConnectionData]

var _whitelist: PackedStringArray

func _init() -> void:
	add_state("Start", StateStart.new(), Vector2(912, 475))
	add_state("End", StateEnd.new(), Vector2(1287, 475))
	
	_whitelist.append("Start")
	_whitelist.append("End")

func _validate_property(property: Dictionary) -> void:
	if (
		property.name == "_states" or 
		property.name == "_connections"
	):
		property.usage = PROPERTY_USAGE_NO_EDITOR

func add_state(name: String, state: State, ui_position := Vector2.ZERO) -> void:
	if has_state(name):
		push_error(name, " already exists.")
		return
	
	var state_data: StateData = StateData.new()
	state_data.name = name
	state_data.state = state
	state_data.position = ui_position
	_states.append(state_data)
func remove_state(name: String) -> void:
	if not can_be_removed(name):
		return
	
	for state_index in range(_states.size()):
		var state = _states[state_index]
		if state.name == name:
			_states.remove_at(state_index)
			break
	
	for connection_data in _connections.filter(func (cn): return cn.from == name or cn.to == name):
		remove_connection(connection_data.from, connection_data.to)
func get_state(name: String) -> State:
	var fstate: State = null
	for state_data in _states:
		if state_data.name == name: 
			fstate = state_data.state
			break
	return fstate
func get_states() -> PackedStringArray:
	var states := PackedStringArray()
	for state_data in _states:
		states.append(state_data.name)
	return states
func get_state_connections(name: String) -> PackedStringArray:
	var connections: PackedStringArray
	for connection_data in _connections:
		if connection_data.from == name:
			connections.append(connection_data.to)
	return connections
func has_state(name: String) -> bool:
	return get_state(name) != null
func change_state_name(name: String, new_name: String) -> void:
	var state_data := _get_state_data(name)
	if state_data == null:
		push_error(name, " is not a valid state.")
		return
	
	state_data.name = new_name

func add_connection(from: String, to: String, state_connection: StateConnection) -> void:
	if has_connection(from, to):
		return
	
	var connection: StateConnectionData = StateConnectionData.new()
	connection.from = from
	connection.to = to
	connection.state_connection = state_connection
	_connections.append(connection)
func remove_connection(from: String, to: String) -> void:
	if not has_connection(from, to):
		return
	
	for connection_index in range(_connections.size()):
		var connection = _connections[connection_index]
		if connection.from == from and connection.to == to:
			_connections.remove_at(connection_index)
			break
func get_connection(from: String, to: String) -> StateConnection:
	for connection in _connections:
		if connection.from == from and connection.to == to:
			return connection.state_connection
	return null
func has_connection(from: String, to: String) -> bool:
	return get_connection(from, to) != null

func check_condition(name: String, base: Object = null) -> bool: 
	var state = get_state(name)
	if not state.condition_expression:
		push_error("No condition expression has been added")
	
	var expression := Expression.new()
	expression.parse(state.condition_expression)
	
	var result = expression.execute([], base)
	if expression.has_execute_failed():
		return false
	return result
func get_next(name: String, base: Object = null) -> String:
	var finded_connections: Array[StateConnectionData]
	
	for connection_data in _connections:
		if connection_data.from == name:
			finded_connections.append(connection_data)
	
	finded_connections.sort_custom(func (a, b):
		return a.state_connection.priority > b.state_connection.priority
	)
	
	for connection_data in finded_connections:
		var connection := connection_data.state_connection
		var cond_result := true
		
		if connection.condition_expression:
			var expression := Expression.new()
			expression.parse(connection.condition_expression)
			
			var result = expression.execute([], base)
			if expression.has_execute_failed():
				result = false
		
		if cond_result:
			return connection_data.to
	
	return ""

func can_be_removed(name: String) -> bool:
	if name in _whitelist:
		return false
	return true

func _get_state_data(name: String) -> StateData:
	var fstate_data: StateData = null
	for state_data in _states:
		if state_data.name == name: 
			fstate_data = state_data
			break
	return fstate_data

func _get_ui_state_position(name: String) -> Vector2:
	return _get_state_data(name).position
func _set_ui_state_position(name: String, position: Vector2) -> void:
	_get_state_data(name).position = position
func _generic_name() -> String:
	var _fs_count = _states.filter(func (state): return "New state" in state.name).size()
	return "New state"+"("+str(_fs_count)+")" if _fs_count > 0 else "New state"
