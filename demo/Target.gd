extends Area2D

signal current_index_changed

var _index: int
var _targets: Array
static var _current_target_indx: int = 0

var collision_shape: CollisionShape2D

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	for child in get_children():
		if child is CollisionShape2D:
			collision_shape = child
			break
	collision_shape.disabled = true
	
	_targets = get_tree().get_nodes_in_group("target")
	for i in range(_targets.size()):
		if self == _targets[i]:
			_index = i
		current_index_changed.connect(_targets[i]._on_current_index_changed)
	if _index == 0:
		collision_shape.disabled = false

func _on_body_entered(body) -> void:
	if body.is_in_group("character"):
		_current_target_indx += 1
		if _current_target_indx >= _targets.size():
			_current_target_indx = 0
		current_index_changed.emit()

func _on_current_index_changed() -> void:
	if _index == _current_target_indx:
		collision_shape.set_deferred("disabled", false)
	else:
		collision_shape.set_deferred("disabled", true)
