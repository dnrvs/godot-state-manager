@tool
extends StateTimeBase
class_name StateTimer

@export var wait_time: float = 0 :
	set(n_wait_time):
		if n_wait_time != wait_time:
			wait_time = n_wait_time
			set_wait_time(wait_time)
