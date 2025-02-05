@tool
extends EditorPlugin

# Scripts
const state_manager = preload("res://addons/state_manager/StateManager.gd")

# Icons
const icon_state_manager = preload("res://addons/state_manager/icons/state_manager.png")

var state_ui: Node = null
var current_state_manager: StateManager = null

func _enter_tree():
	var feature_profie := EditorFeatureProfile.new()
	
	add_custom_type("StateManager", "Node", state_manager, icon_state_manager)
	
	state_ui = preload("res://addons/state_manager/ui/state_ui.tscn").instantiate()
	state_ui._undo_redo = get_undo_redo()
	
	var editor_selection = EditorInterface.get_selection()
	editor_selection.selection_changed.connect(func ():
		var selection = editor_selection.get_selected_nodes()
		
		if not selection.is_empty() and selection[0] is StateManager:
			current_state_manager = selection[0]
			_add_state_tree()
		elif current_state_manager != null:
			if current_state_manager.is_inside_tree():
				_remove_state_tree()
			current_state_manager = null
	)

func _add_state_tree() -> void:
	if current_state_manager == null:
		return
	
	add_control_to_bottom_panel(state_ui, "State Tree")
	state_ui.load_state_machine(current_state_manager.state_machine)
	
	current_state_manager.state_machine_changed.connect(state_ui.load_state_machine)
	current_state_manager.tree_exiting.connect(_remove_state_tree)
func _remove_state_tree() -> void:
	if current_state_manager == null:
		return
	
	current_state_manager.state_machine_changed.disconnect(state_ui.load_state_machine)
	current_state_manager.tree_exiting.disconnect(_remove_state_tree)
	
	state_ui.clear()
	remove_control_from_bottom_panel(state_ui)

func _exit_tree():
	remove_custom_type("StateManager")
	
	remove_control_from_bottom_panel(state_ui)
	state_ui.queue_free()

func _get_plugin_name() -> String: return "StateManager"
func _get_plugin_icon() -> Texture2D: return EditorInterface.get_editor_theme().get_icon("Node", "EditorIcons")
