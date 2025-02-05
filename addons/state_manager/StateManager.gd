@tool
extends Node
class_name StateManager

signal state_machine_changed(state_machine)
signal state_changed(state)


var _current_state: String = ""

@export var state_machine: StateMachine :
	set(val):
		state_machine = val
		state_machine_changed.emit(state_machine)

@export var condition_expression_base_node: NodePath :
	set(val):
		condition_expression_base_node = val
		if not Engine.is_editor_hint():
			if not is_node_ready():
				await ready
			_cond_base_node = get_node_or_null(condition_expression_base_node)
var _cond_base_node: Node

enum CheckMode {AUTO, MANUAL}
@export var check_mode: CheckMode = CheckMode.AUTO
var _is_checking: bool = false

func _ready() -> void:
	_advance()

func _process(delta: float) -> void:
	if not Engine.is_editor_hint():
		if check_mode == CheckMode.AUTO:
			check_condition()

func check_condition() -> void:
	if _is_checking:
		return
	_is_checking = true
	if state_machine.check_condition(_current_state, _cond_base_node):
		await _advance()
	_is_checking = false

func get_current_state() -> String:
	return _current_state

func _advance() -> void:
	if not _current_state:
		_current_state = "Start"
		state_changed.emit(_current_state)
		return
	if _current_state == "End":
		return
	
	var cond_base = _cond_base_node
	var custom_base = state_machine.get_state(_current_state).custom_condition_expression_base
	if custom_base:
		cond_base = get_node_or_null(custom_base)
	
	var state_signal_name = state_machine.get_state(_current_state).condition_signal
	if state_signal_name:
		var state_signal = cond_base.get_indexed(state_signal_name)
		if state_signal:
			await state_signal
		else:
			push_error("Invalid condition signal")
	var next_state := state_machine.get_next(_current_state, cond_base)
	if next_state:
		_current_state = next_state
		state_changed.emit(_current_state)
