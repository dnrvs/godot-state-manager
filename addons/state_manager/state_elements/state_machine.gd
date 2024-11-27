@tool
extends Resource
class_name StateMachine

var _states: Array[_StateData]
var _connections: Array[_StateConnectionData]

func _init() -> void:
	add_state("Start", NState.new(), Vector2(912, 475))
	add_state("End", NState.new(), Vector2(1287, 475))

func _validate_property(property: Dictionary) -> void:
	if (
		property.name == "_states" or 
		property.name == "_connections"
	):
		property.usage = PROPERTY_USAGE_NO_EDITOR

func add_state(name: String, state: NState, ui_position := Vector2.ZERO) -> void:
	if has_state(name):
		push_error(name, " already exists.")
		return
	
	var state_data: _StateData = _StateData.new()
	state_data.name = name
	state_data.state = state
	state_data.position = ui_position
	_states.append(state_data)
func remove_state(name: String) -> void:
	if name == "Start" or name == "End":
		return
	_states = _states.filter(func (state_data): return state_data.name != name)
func get_state(name: String) -> NState:
	var fstate: NState = null
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
func has_state(name: String) -> bool:
	return get_state(name) != null
func change_state_name(name: String, new_name: String) -> void:
	var state_data := _get_state_data(name)
	if state_data == null:
		push_error(name, " is not a valid state.")
		return
	
	state_data.name = new_name

func add_connection(from: String, to: String, state_connection: StateConnection) -> void:
	for connection in _connections:
		if connection.from == from and connection.to == to: return
	
	var connection: _StateConnectionData = _StateConnectionData.new()
	connection.from = from
	connection.to = to
	connection.state_connection = state_connection
	_connections.append(connection)

func check_condition(name: String, base: Object = null) -> bool: 
	var state = get_state(name)
	
	var expression := Expression.new()
	expression.parse(state.condition_expression)
	
	var result = expression.execute([], base)
	if expression.has_execute_failed():
		return false
	return result
func get_next(name: String, base: Object = null) -> String:
	var finded_connections: Array[_StateConnectionData]
	
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

func _get_state_data(name: String) -> _StateData:
	var fstate_data: _StateData = null
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
