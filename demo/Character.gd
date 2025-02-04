extends CharacterBody2D


const SPEED: float = 150.0

@onready var state_manager = $StateManager
@onready var wait_timer = $Timer 
@onready var animated_sprite = $AnimatedSprite2D

var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")
var direction: int = 1
var final_direction: int = direction

func _ready() -> void:
	state_manager.state_changed.connect(_state_changed)

func _physics_process(delta) -> void:
	var current_state = state_manager.get_current_state()
	get_tree().get_nodes_in_group("state_label")[0].text = current_state
	
	if not is_on_floor():
		velocity.y += gravity * delta
	
	if final_direction:
		velocity.x = final_direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	move_and_slide()
	animated_sprite.flip_h = true if direction == -1 else false

func collided_with_target() -> bool:
	var collided = false
	for area in $Area2D.get_overlapping_areas():
		if area.is_in_group("target"):
			collided = true
	return collided

func _state_changed(state) -> void:
	match state:
		"idle":
			wait_timer.start()
			final_direction = 0
			animated_sprite.play("idle")
		"walk":
			direction *= -1
			final_direction = direction
			animated_sprite.play("walk")
		"attack":
			final_direction = 0
			animated_sprite.play("attack")
