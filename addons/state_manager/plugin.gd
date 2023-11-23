@tool
extends EditorPlugin

# Scripts
const state_manager = preload("res://addons/state_manager/StateManager.gd")
const states = {
	state = preload("res://addons/state_manager/states/State.gd"),
	state_condition = preload("res://addons/state_manager/states/StateCondition.gd"),
	state_timer = preload("res://addons/state_manager/states/StateTimer.gd"),
	state_rand_timer = preload("res://addons/state_manager/states/StateRandTimer.gd")
}

# Icons
const icons = {
	state_manager = preload("res://addons/state_manager/icons/state_manager.png"),
	state_condition = preload("res://addons/state_manager/icons/state_condition.png"),
	state_timer = preload("res://addons/state_manager/icons/state_timer.png"),
	state_rand_timer = preload("res://addons/state_manager/icons/state_rand_timer.png")
}

func _enter_tree():
	add_custom_type("StateManager", "Node", state_manager, icons.state_manager)
	add_custom_type("StateCondition", "State", states.state_condition, icons.state_condition)
	add_custom_type("StateTimer", "StateTimeBase", states.state_timer, icons.state_timer)
	add_custom_type("StateRandTimer", "StateTimeBase", states.state_rand_timer, icons.state_timer)


func _exit_tree():
	remove_custom_type("StateManager")
	remove_custom_type("StateCondition")
	remove_custom_type("StateTimer")
	remove_custom_type("StateRandTimer")
