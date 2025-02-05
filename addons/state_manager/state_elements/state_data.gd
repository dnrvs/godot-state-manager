@tool
extends Resource

var name: String
var position: Vector2
var state: State

func _validate_property(property: Dictionary) -> void:
	if (
		property.name == "name" or
		property.name == "position" or 
		property.name == "state"
	):
		property.usage = PROPERTY_USAGE_NO_EDITOR
