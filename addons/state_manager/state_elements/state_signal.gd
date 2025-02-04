@tool
extends State
class_name StateSignal



func _init() -> void:
	self.condition_expression
#var _signal_emitted: bool = false
"""
func _init() -> void:
	if not Engine.is_editor_hint():
		if not cond_signal.is_null():
			_detect_sign()
		else:
			push_error("There is no signal")

func _validate_property(property: Dictionary) -> void:
	if property.name == "condition_expression": property.usage = PROPERTY_USAGE_NO_EDITOR

func get_condition_expression() -> String:
	return str(_signal_emitted)

func _detect_sign() -> void:
	while true:
		await cond_signal
		_signal_emitted = true
		call_deferred("set_deferred", "_signal_emitted", false)
"""
