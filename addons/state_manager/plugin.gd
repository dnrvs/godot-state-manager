@tool
extends EditorPlugin

# Scripts
const state_manager = preload("res://addons/state_manager/StateManager.gd")
const state = preload("res://addons/state_manager/states/State.gd")
const states = {
	state_group = preload("res://addons/state_manager/states/StateGroup.gd"),
	state_condition = preload("res://addons/state_manager/states/StateCondition.gd"),
	state_timer = preload("res://addons/state_manager/states/StateTimer.gd"),
	state_rand_timer = preload("res://addons/state_manager/states/StateRandTimer.gd")
}

# Icons
const icons = {
	state_manager = preload("res://addons/state_manager/icons/state_manager.png"),
	state_group = preload("res://addons/state_manager/icons/state_group.png"),
	state_condition = preload("res://addons/state_manager/icons/state_condition.png"),
	state_timer = preload("res://addons/state_manager/icons/state_timer.png"),
	state_rand_timer = preload("res://addons/state_manager/icons/state_rand_timer.png")
}

var state_ui: Node = null
var current_state_manager: StateManager = null

func _enter_tree():
	var feature_profie := EditorFeatureProfile.new()
	
	add_custom_type("StateManager", "Node", state_manager, icons.state_manager)
	add_custom_type("State", "Node", state, icons.state_condition)
	add_custom_type("StateGroup", "State", states.state_group, icons.state_group)
	#add_custom_type("StateCondition", "State", states.state_condition, icons.state_condition)
	add_custom_type("StateTimer", "StateTimeBase", states.state_timer, icons.state_timer)
	add_custom_type("StateRandTimer", "StateTimeBase", states.state_rand_timer, icons.state_timer)
	
	state_ui = preload("res://addons/state_manager/ui/state_ui.tscn").instantiate()
	
	var editor_selection = EditorInterface.get_selection()
	#var _updt_machine_fn = func (statemachine): state_ui.load_
	editor_selection.selection_changed.connect(func ():
		var selection = editor_selection.get_selected_nodes()
		
		if not selection.is_empty() and selection[0] is StateManager:
			current_state_manager = selection[0]
			add_control_to_bottom_panel(state_ui, "State Tree")
			state_ui.load_statemachine(current_state_manager.state_machine)
			
			current_state_manager.state_machine_changed.connect(state_ui.load_statemachine)
		elif current_state_manager != null:
			if current_state_manager.state_machine_changed.is_connected(state_ui.load_statemachine):
				current_state_manager.state_machine_changed.disconnect(state_ui.load_statemachine)
			
			state_ui.clear()
			remove_control_from_bottom_panel(state_ui)
			
			current_state_manager = null
	)

func _exit_tree():
	remove_custom_type("StateManager")
	remove_custom_type("State")
	remove_custom_type("StateGroup")
	#remove_custom_type("StateCondition")
	remove_custom_type("StateTimer")
	remove_custom_type("StateRandTimer")
	
	remove_control_from_bottom_panel(state_ui)
	state_ui.queue_free()

func _get_plugin_name() -> String: return "StateManager"
func _get_plugin_icon() -> Texture2D: return EditorInterface.get_editor_theme().get_icon("Node", "EditorIcons")
