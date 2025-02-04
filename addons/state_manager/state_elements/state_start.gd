@tool
extends State
class_name StateStart

func _init() -> void:
	self.condition_expression = "true"

func _validate_property(property: Dictionary) -> void:
	if property.name == "condition_expression": property.usage = PROPERTY_USAGE_NO_EDITOR
