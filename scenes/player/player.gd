extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -400.0

@onready var stamina_bar: ProgressBar = $"../StaminaBar/ProgressBar"

var is_on_ladder: bool = false
var gravity: Vector2 = Vector2(0.0, 980.0)



func _physics_process(delta: float) -> void:
	var vertical_direction := Input.get_axis("move_up", "move_down")
	if is_on_ladder:
		if vertical_direction:
			gravity = Vector2 (0, 0)
			velocity.y = vertical_direction * 50
		else:
			velocity.y = 0
	# Add the gravity.
	if not is_on_floor() and not is_on_ladder:
		velocity += gravity * delta

	# Handle jump.
	if stamina_bar.value > 1 and Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		stamina_bar.reduce_after_jump()

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("move_left", "move_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
	

func _on_stairs_area_entered(area: Area2D) -> void:
	print("ESTOY AQUI")
	is_on_ladder = true



func _on_stairs_area_exited(area: Area2D) -> void:
	is_on_ladder = false
	gravity = Vector2 (0, 980)
