@tool
extends Resource

var from: String
var to: String
var state_connection: StateConnection

func _validate_property(property: Dictionary) -> void:
	if (
		property.name == "from" or
		property.name == "to" or 
		property.name == "state_connection"
	):
		property.usage = PROPERTY_USAGE_NO_EDITOR
