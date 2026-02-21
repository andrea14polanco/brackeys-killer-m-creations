extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -400.0
const CLIMBING_SPEED = 100

@onready var stamina_bar: ProgressBar = $"../StaminaBar/ProgressBar"

signal player_take_stairs

var is_on_ladder: bool = false
var is_on_stairs: bool = false
var is_jumping: bool = false
var gravity: Vector2 = Vector2(0.0, 980.0)
var facing_right = true


func _physics_process(delta: float) -> void:
	
	# Add the gravity.
	if not is_on_floor() and not is_on_ladder:
		velocity += gravity * delta

	# Handle jump.
	if stamina_bar.value > 1 and Input.is_action_just_pressed("jump") and not is_jumping:
			is_jumping = true
			velocity.y = JUMP_VELOCITY
			stamina_bar.reduce_after_jump()
	else:
		is_jumping = false

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var horizontal_direction := Input.get_axis("move_left", "move_right")
	if horizontal_direction:
		velocity.x = horizontal_direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	
	var vertical_direction := Input.get_axis("move_up", "move_down")
	if is_on_ladder:
		if vertical_direction:
			gravity = Vector2 (0, 0)
			velocity.y = vertical_direction * CLIMBING_SPEED
		else:
			velocity.y = 0
	elif is_on_stairs:
		if vertical_direction:
			player_take_stairs.emit()
			
	move_and_slide()
	
	# Sprite direction and smoke pos
	
	if is_on_ladder:
		$AnimatedSprite2D.play("climb")
		if velocity.y == 0:
			$AnimatedSprite2D.play("idle_climb")
	elif velocity.x > 0:
		$AnimatedSprite2D.play("walk_right")
		facing_right = true
	elif velocity.x < 0:
		$AnimatedSprite2D.play("walk_left")
		facing_right = false
	elif velocity.x == 0 and not is_on_ladder:
		if facing_right:
			$AnimatedSprite2D.play("idle_right")
		else:
			$AnimatedSprite2D.play("idle_left")
	

func _on_stairs_area_entered(area: Area2D) -> void:
	is_on_ladder = true



func _on_stairs_area_exited(area: Area2D) -> void:
	is_on_ladder = false
	gravity = Vector2 (0, 980)
