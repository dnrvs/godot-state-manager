@tool
extends State
class_name StateCondition

@export var condition_callable: Callable = func (): return null :
	set(val):
		if not val.is_null():
			assert(val.call() is bool, "Invalid return value.")
			condition_callable = val
@export var negative_condition: bool = false # if true then when the condition is true it will advance to the next state

func _process(_delta):
	if not Engine.is_editor_hint():
		print(condition_callable.call())
		if is_state_processing():
			if condition_callable.call() != null:
				var _condition = condition_callable.call()
				var _final_condition = _condition if not negative_condition else !_condition
				if not _final_condition:
					_finish_state()
		super(_delta)
