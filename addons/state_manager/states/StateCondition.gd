@tool
extends State
#class_name StateCondition

func _init() -> void:
	self.condition_callable = func (): return false
	self.cancelable = true

func _validate_property(property: Dictionary) -> void:
	if property.name == "cancelable":
		property.usage = PROPERTY_USAGE_NONE
