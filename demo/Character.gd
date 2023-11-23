extends CharacterBody2D


const SPEED: float = 150.0

@onready var state_manager = $StateManager

var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")
var direction: int = 1
var final_direction: int = direction

func _enter_tree() -> void:
	$StateManager/WalkUntilCollide.started_state.connect(func ():
		direction *= -1
		final_direction = direction
		$AnimatedSprite2D.play("walk")
	)
	$StateManager/Attack.started_state.connect(func ():
		final_direction = 0
		$AnimatedSprite2D.play("attack")
	)
	$StateManager/Idle.started_state.connect(func ():
		final_direction = 0
		$AnimatedSprite2D.play("idle")
	)

func _physics_process(delta) -> void:
	var current_state = state_manager.get_current_state_tag()
	get_tree().get_nodes_in_group("state_label")[0].text = current_state
	
	if not is_on_floor():
		velocity.y += gravity * delta
	
	if final_direction:
		velocity.x = final_direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	move_and_slide()
	$AnimatedSprite2D.flip_h = true if direction == -1 else false

func collided_with_target() -> bool:
	var collided = false
	for area in $Area2D.get_overlapping_areas():
		if area.is_in_group("target"):
			collided = true
	return collided
