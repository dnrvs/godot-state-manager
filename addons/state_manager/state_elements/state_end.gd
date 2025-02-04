@tool
extends State
class_name StateEnd

func _validate_property(property: Dictionary) -> void:
	if property.name == "condition_expression": property.usage = PROPERTY_USAGE_NO_EDITOR
