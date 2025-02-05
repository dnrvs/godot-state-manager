@tool
extends "graph_element.gd"

signal tag_changed(tag, new_tag)
signal position_changed(pos)
signal position_update(pos)

var panel: PanelContainer
var tag_line_edit: LineEdit
var _select_panel: PanelContainer

var _old_pos = null

func _ready() -> void:
	set_notify_transform(true)
	
	panel = $Panel
	tag_line_edit = $Panel/MarginContainer/LineEdit
	_select_panel = $SelectPanel
	
	get_viewport().gui_focus_changed.connect(func (control) -> void:
		if control == self or is_ancestor_of(control):
			_select_panel.visible = true
			if tag_line_edit.editable:
				tag_line_edit.mouse_filter = Control.MOUSE_FILTER_STOP
		else:
			_select_panel.visible = false
			tag_line_edit.mouse_filter = Control.MOUSE_FILTER_IGNORE
	)

func _process(_delta: float) -> void:
	if _old_pos != position:
		position_update.emit(position)
		_old_pos = position

func _set_tag(val) -> void:
	super(val)
	tag_line_edit.text = tag

func grab(to: Vector2) -> void:
	position = to
