@tool
extends Resource
class_name NState

#@export var tag: String
@export var condition_expression: String

#func _validate_property(property: Dictionary) -> void:
#	if property.name == "tag": property.usage = PROPERTY_USAGE_NO_EDITOR
