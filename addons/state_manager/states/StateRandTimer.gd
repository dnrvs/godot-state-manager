@tool
extends StateTimeBase
class_name StateRandTimer

@export var from: float = 0
@export var to: float = 0

func start() -> void:
	set_wait_time(randf_range(from, to))
	super()
