extends StaticBody2D

@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D

const ROTATION_LIMIT = 45

var is_player_on_stairs
var is_rotated

var player_nearby: bool = false
var is_flat: bool = false


func _ready() -> void:
	collision_shape_2d.set_deferred("disabled", true)

func _physics_process(delta: float) -> void:
	var titanic_angle = abs(GameManager.titanic.global_rotation_degrees)
	is_rotated = titanic_angle > ROTATION_LIMIT

	if is_rotated:
		collision_shape_2d.set_deferred("disabled", false)
		return

	var player: CharacterBody2D = GameManager.player
	if player == null or player.is_on_ladder:
		return

	if not player_nearby:
		collision_shape_2d.set_deferred("disabled", true)
		return

	# Press UP → walk onto the ramp
	if Input.is_action_just_pressed("move_up"):
		collision_shape_2d.set_deferred("disabled", false)

	# Falling onto it → land on the ramp
	if not player.is_on_floor() and player.velocity.y > 0:
		collision_shape_2d.set_deferred("disabled", false)


func _on_detection_zone_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_nearby = true
		if not is_rotated:
			collision_shape_2d.set_deferred("disabled", true)


func _on_detection_zone_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_nearby = false
		if not is_rotated:
			collision_shape_2d.set_deferred("disabled", true)
