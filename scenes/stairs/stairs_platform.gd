extends StaticBody2D

@onready var col: CollisionShape2D = $StairCol
@onready var detection_area: Area2D = $DetectionZone

const LIMIT_DEGREES = 25

var player_nearby: bool = false
var player_using_stair: bool = false
var is_flat: bool = false


func _ready() -> void:
	col.disabled = true


func _physics_process(delta: float) -> void:
	_update_flat_state()

	if is_flat:
		col.disabled = false
		player_using_stair = false
		return

	var player: CharacterBody2D = GameManager.player
	if player == null:
		return

	if player.is_on_ladder:
		return

	if not player_nearby:
		if not player_using_stair:
			col.disabled = true
		return

	# Press UP near stairs → enable collision, player walks on the ramp
	if Input.is_action_just_pressed("move_up") and not player_using_stair:
		player_using_stair = true
		col.disabled = false

	# Jumping near stairs → enable collision so player can land on it
	if not player_using_stair and not player.is_on_floor() and player.velocity.y > 0:
		col.disabled = false

	# On the stair and jumps → let them leave
	if player_using_stair and Input.is_action_just_pressed("jump"):
		player_using_stair = false
		col.disabled = true


func _update_flat_state() -> void:
	var angle = abs(fmod(global_rotation_degrees, 180.0))
	is_flat = angle < LIMIT_DEGREES or angle > (180.0 - LIMIT_DEGREES)


func _on_detection_zone_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_nearby = true


func _on_detection_zone_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_nearby = false
		player_using_stair = false
		if not is_flat:
			col.disabled = true
