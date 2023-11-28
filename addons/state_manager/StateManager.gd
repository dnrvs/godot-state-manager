@tool
extends Node
class_name StateManager

var _states: Array[State]
var _current_state_index: int = 0
var _states_path: Array

var _is_processing: bool = false

var _has_final_state: bool = false

@export var autostart: bool = true
@export var one_loop: bool = false

class _FinalState extends State:
	pass

func _get_configuration_warnings() -> PackedStringArray:
	var warnings = []
	
	if get_child_count() == 0:
		warnings.append("No State has been added yet.")
	
	for child in get_children():
		if not child is State:
			warnings.append("This node was only created to manage state nodes.")
			break
	
	return warnings

func _enter_tree() -> void:
	if not Engine.is_editor_hint():
		child_entered_tree.connect(_on_child_entered_tree)
		var final_state = _FinalState.new()
		final_state.tag = "final_state"
		add_child(final_state)

func _ready() -> void:
	if not Engine.is_editor_hint():
		if autostart:
			start()

func start() -> void:
	if _is_processing:
		push_warning("Manager already started")
		return
	if _get_current_state() is _FinalState:
		_current_state_index = 0
	_get_current_state().start()
	_is_processing = true
func stop() -> void:
	if not _is_processing:
		push_warning("Manager already stopped")
		return
	_get_current_state().stop()
	_is_processing = false

func is_manager_processing() -> bool:
	return _is_processing

func _add_state_to_loop(state: State) -> void:
	var _final_state_indx = _states.size()-1
	if _states.size() <= 0:
		_final_state_indx = 0
	_states.insert(_final_state_indx,state)
	state.finished_state.connect(_on_state_finished)
func _get_current_state() -> State:
	return _states[_current_state_index]
func get_current_state_tag() -> String:
	return _get_current_state().tag

func _next_state() -> void:
	if !_get_current_state().is_finished():
		return
	
	_current_state_index += 1
	
	var max_indx = _states.size()-1 if one_loop else _states.size()-2
	if _current_state_index > max_indx:
		_current_state_index = 0
	_get_current_state().start()
func force_next_state() -> void:
	_get_current_state().force_finish_state()
	_next_state()

func _on_child_entered_tree(node: Node) -> void:
	if not Engine.is_editor_hint():
		assert(node is State, "Invalid state: " + node.name)
		_add_state_to_loop(node)

func _on_state_finished() -> void:
	_next_state()
