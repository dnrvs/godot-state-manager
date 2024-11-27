@tool
extends VBoxContainer

func pos_out() -> Vector2: 
	if not get_parent() is Node:
		return $Out.global_position
	return $Out.global_position-get_parent().global_position
func pos_in() -> Vector2: 
	if not get_parent() is Node:
		return $In.global_position
	return $In.global_position-get_parent().global_position
