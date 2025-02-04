@tool
extends Resource
class_name State

@export var custom_expression_base_node: NodePath
@export var condition_signal: String
@export var condition_expression: String# : get = get_condition_expression
"""
var _cond_base: Node

func _init() -> void:
	if not Engine.is_editor_hint():
		var scene_tree = Engine.get_main_loop()
		if not scene_tree.current_scene:
			await scene_tree.node_added
		_cond_base = scene_tree.current_scene.get_node_or_null(condition_expression_base_node)

func get_condition_expression() -> String:
	return condition_expression
"""
