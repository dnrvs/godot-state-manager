extends CharacterBody2D


const SPEED: float = 150.0

@onready var state_manager = $StateManager

var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")
var direction: int = -1

func _physics_process(delta) -> void:
	var current_state = state_manager.get_current_state_tag()
	get_tree().get_nodes_in_group("state_label")[0].text = current_state
	
	if not is_on_floor():
		velocity.y += gravity * delta
	
	var final_direction = Vector2.ZERO
	var anim = "idle"
	
	match current_state:
		"walk_until_collide":
			final_direction = direction
			anim = "walk"
		"attack":
			anim = "attack"
		"idle":
			pass
	
	if final_direction:
		velocity.x = final_direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	move_and_slide()
	$AnimatedSprite2D.flip_h = true if direction == -1 else false
	$AnimatedSprite2D.play(anim)

func collided_with_target() -> bool:
	var collided = false
	for area in $Area2D.get_overlapping_areas():
		if area.is_in_group("target"):
			collided = true
	return collided

func _on_state_manager_state_changed(state_tag):
	if state_tag == "walk_until_collide":
		direction *= -1
