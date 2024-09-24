@tool
extends Node

class_name State

signal started_state
signal processing_state
signal finished_state

@export var condition_callable: Callable = func (): return true :
	set(val):
		if not val.is_null():
			assert(val.call() is bool or val.call() == null, "Invalid return value.")
			condition_callable = val
@export var negative_condition: bool = false # if true then when the condition is true it will advance to the next state
@export var tag: String = "" :
	set(n_tag):
		if n_tag != tag:
			tag = n_tag
			update_configuration_warnings()
@export var cancelable: bool = false

var _is_processing: bool = false : 
	set(val):
		if val == true:
			_is_finished = false
		_is_processing = val
var _is_finished: bool = false : 
	set(val):
		if val == true:
			_is_processing = false
		_is_finished = val


func _init() -> void:
	if get_script().get_global_name() == "State":
		condition_callable = func (): return null
		cancelable = true

func _validate_property(property: Dictionary) -> void:
	if property.name == "cancelable" and get_script().get_global_name() == "State":
		property.usage = PROPERTY_USAGE_NONE

func _get_configuration_warnings() -> PackedStringArray:
	var warnings = []
	
	if get_child_count() > 0:
		warnings.append("This node is not designed to contain other nodes.")
	if not get_parent() is StateManager and not get_parent() is StateGroup:
		warnings.append("This node is designed to be a child of a StateManager or a StateGroup.")
	
	if tag == "":
		warnings.append("Please set 'tag' to a non-empty value.")
	
	return warnings

func start() -> void:
	_is_processing = true
	started_state.emit()
func stop() -> void:
	_is_processing = false

func _process(_delta) -> void:
	if not Engine.is_editor_hint():
		if is_state_processing():
			if not check_condition() and cancelable:
				_finish_state()
				return
			processing_state.emit()

func is_state_processing() -> bool:
	return _is_processing
func is_finished() -> bool:
	return _is_finished

func check_condition() -> bool:
	var _condition = condition_callable.call()
	if _condition == null:
		return false
	return _condition if not negative_condition else !_condition

func _finish_state() -> void:
	_is_finished = true
	finished_state.emit()
func force_finish_state() -> void:
	_finish_state()
