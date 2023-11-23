#@tool
extends Node

class_name State

signal started_state
signal processing_state
signal finished_state

@export var tag: String = "" :
	set(n_tag):
		if n_tag != tag:
			tag = n_tag
			update_configuration_warnings()

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

func _get_configuration_warnings() -> PackedStringArray:
	var warnings = []
	
	if get_child_count() > 0:
		warnings.append("This node is not designed to contain other nodes.")
	if not get_parent() is StateManager:
		warnings.append("This node is designed to be a child of a StateManager.")
	
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
		if _is_processing:
			processing_state.emit()

func is_state_processing() -> bool:
	return _is_processing
func is_finished() -> bool:
	return _is_finished

func _finish_state() -> void:
	_is_finished = true
	finished_state.emit()
func force_finish_state() -> void:
	_finish_state()
