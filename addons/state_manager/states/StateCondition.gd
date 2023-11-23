@tool
extends State

class_name StateCondition

@export var node_path: NodePath :
	set(n_path):
		if n_path != node_path:
			node_path = n_path
			update_configuration_warnings()
@export var property_name: String : # Supports both variables and callables as long as they return boolean values
	set(n_property):
		if n_property != property_name:
			property_name = n_property
			update_configuration_warnings()
@export var negative_condition: bool = false # if true then when the condition is true it will advance to the next state

func _get_configuration_warnings():
	var warnings = super()
	
	if node_path.is_empty():
		warnings.append("There is no path to the Node.")
	# Check if property is valid
	"""else:
		var node = get_node(node_path)
		var script = node.get_script()
		var property_list = node.get_property_list()
		if not script == null:
			property_list = script.get_property_list()
		for property in property_list:
			if property.name == property:
				warnings.append("Invalid property")
				break
	"""
	
	return warnings

func _process(_delta):
	if not Engine.is_editor_hint():
		super(_delta)
		if is_state_processing():
			var _node_property = get_node(node_path).get(property_name)
			var _condition = null
			if _node_property is Callable:
				_condition = _node_property.call()
			elif _node_property is bool:
				_condition = _node_property
			
			var final_condition = _condition if not negative_condition else !_condition
			if not final_condition:
				_finish_state()
