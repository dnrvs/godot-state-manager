@tool
extends State
class_name StateStart

func _init() -> void:
	self.condition_expression = "true"

func _validate_property(property: Dictionary) -> void:
	if (
			property.name == "custom_condition_expression_base" or
			property.name == "condition_signal" or
			property.name == "condition_expression"
	): 
		property.usage = PROPERTY_USAGE_NO_EDITOR
