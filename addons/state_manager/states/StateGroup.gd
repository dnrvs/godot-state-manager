@tool
extends State
class_name StateGroup

var _states: Array[State]
var _current_state_index: int = 0

func _get_configuration_warnings() -> PackedStringArray:
	var warnings = []
	
	if get_child_count() <= 0:
		warnings.append("No State has been added yet.")
	for child in get_children():
		if not child is State:
			warnings.append("This state needs to contain other state nodes to function.")
			break
	
	if not get_parent() is StateManager:
		warnings.append("This node is designed to be a child of a StateManager.")
	
	if tag == "":
		warnings.append("Please set 'tag' to a non-empty value.")
	
	return warnings

func _enter_tree() -> void:
	if not Engine.is_editor_hint():
		child_entered_tree.connect(func (node: Node):
			assert(node is State)
			_add_state_to_loop(node)
		)

func start() -> void:
	super()
	if _states.size() <= 0:
		_finish_state()
		return
	_get_current_state().start()

func stop() -> void:
	super()
	_get_current_state().stop()

func _get_current_state() -> State:
	return _states[_current_state_index]
func get_current_state_tag() -> String:
	return _get_current_state().tag

func _add_state_to_loop(state: State) -> void:
	_states.push_back(state)
	state.finished_state.connect(_on_state_finished)

func _on_state_finished() -> void:
	if !_get_current_state().is_finished():
		return
	_current_state_index += 1
	if _current_state_index > _states.size()-1:
		_current_state_index = 0
		_finish_state()
	else:
		_get_current_state().start()
