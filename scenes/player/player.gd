extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -400.0
const CLIMBING_SPEED = 100
const SLOPE_SLIDE_THRESHOLD = deg_to_rad(10.0)
const SLOPE_FULL_SLIDE_ANGLE = deg_to_rad(55.0)
const MAX_SLIDE_SPEED = 500.0
const UPHILL_SPEED_PENALTY = 0.5
const FLOOR_DETECT_BLEND_START = deg_to_rad(45.0)
const FLOOR_DETECT_BLEND_END = deg_to_rad(58.0)
enum Location {
	Forrest,
	Ship
}
@onready var stamina_bar: ProgressBar = $"../../StaminaBar/ProgressBar"
@onready var animated_sprite_2d = $AnimatedSprite2D
var original_material: ShaderMaterial
@onready var forrest_camera: Camera2D = $"../../forrest/Camera2D"

signal player_take_stairs

var is_on_ladder: bool = false
var is_on_stairs: bool = false
var is_jumping: bool = false
var facing_right = true
var teleporting = false
var player_location: Location = Location.Ship:
	set(value):
		if player_location != value:
			player_location = value
			play_bgm()
var current_sfx_name: String = ""
var current_bgm_name: String = ""

func _ready() -> void:
	GameManager.player = self
	original_material = animated_sprite_2d.material
	animated_sprite_2d.material = null
	current_sfx_name = ""
	current_bgm_name = ""
	floor_constant_speed = false
	

func _physics_process(delta: float) -> void:
	# Blend up_direction: track deck at low angles, fade to global UP at steep angles
	var abs_angle = abs(global_rotation)
	if abs_angle < FLOOR_DETECT_BLEND_START:
		up_direction = Vector2.UP.rotated(global_rotation)
	elif abs_angle > FLOOR_DETECT_BLEND_END:
		up_direction = Vector2.UP
	else:
		var blend_t = (abs_angle - FLOOR_DETECT_BLEND_START) / (FLOOR_DETECT_BLEND_END - FLOOR_DETECT_BLEND_START)
		up_direction = Vector2.UP.rotated(global_rotation).lerp(Vector2.UP, blend_t).normalized()

	# Convert global velocity to local (deck-relative) space
	velocity = velocity.rotated(-global_rotation)

	handle_jump()
	handle_movement()
	handle_slope_sliding(delta)
	handle_sprite_animations()
	handle_forrest_background()

	# Keep sprite visually upright while ship tilts
	animated_sprite_2d.rotation = -global_rotation

	# Convert local velocity back to global for move_and_slide
	velocity = velocity.rotated(global_rotation)

	# Apply gravity in GLOBAL space when airborne
	handle_gravity(delta)

	move_and_slide()
	

func start_teleport():
	AudioManager.stop("WalkingMetal")
	AudioManager.stop("WalkingGround")
	teleporting = true
	animated_sprite_2d.material = original_material
	AudioManager.play("TeleportCast")
	var tween = create_tween()
	tween.tween_method(
		func(v): animated_sprite_2d.material.set_shader_parameter("progress", v),
		0.0, 1.0, 2.0
	)
	await tween.finished
	
func stop_teleport():
	teleporting = false
	animated_sprite_2d.material = null
	
func play_walking_sfx(walking_direction):
	var new_audio_name = ""
	if player_location == Location.Ship:
		new_audio_name = "WalkingMetal"
	elif player_location == Location.Forrest:
		new_audio_name = "WalkingGround"

	if current_sfx_name != new_audio_name and current_sfx_name != "":
		AudioManager.stop(current_sfx_name)

	current_sfx_name = new_audio_name

	if walking_direction != 0:
		AudioManager.play(current_sfx_name)
		AudioManager.pause(current_sfx_name, false)
	else:
		AudioManager.pause(current_sfx_name, true)
	
func play_bgm():
	var new_music_name = ""

	if player_location == Location.Ship:
		new_music_name = "TitanicMusic"
	elif player_location == Location.Forrest:
		new_music_name = "Forest"

	if current_bgm_name != new_music_name and current_bgm_name != "":
		AudioManager.stop(current_bgm_name)

	current_bgm_name = new_music_name
	if not AudioManager.is_audio_playing(current_bgm_name):
		AudioManager.play(current_bgm_name)
	
func handle_gravity(delta):
	if not is_on_floor() and not is_on_ladder:
		# Gravity in global space — real downward pull
		velocity += get_gravity() * delta
		is_jumping = true
	
func handle_slope_sliding(delta: float) -> void:
	if not is_on_floor() or is_on_ladder or player_location != Location.Ship:
		return

	var abs_angle = abs(global_rotation)
	if abs_angle < SLOPE_SLIDE_THRESHOLD:
		return

	# sin(global_rotation) * gravity pushes player downhill in local X
	var slide_strength = sin(global_rotation) * get_gravity().length()
	velocity.x += slide_strength * delta

	# Cap slide speed proportional to angle (gentle drift at small tilts, fast at steep)
	var angle_ratio = sin(abs_angle) / sin(SLOPE_FULL_SLIDE_ANGLE)
	var max_speed = MAX_SLIDE_SPEED * clampf(angle_ratio, 0.1, 1.0)
	velocity.x = clampf(velocity.x, -max_speed, max_speed)

func handle_jump():
	if is_on_floor():
		is_jumping = false
		if stamina_bar.value > 1 and Input.is_action_just_pressed("jump"):
				is_jumping = true
				velocity.y = JUMP_VELOCITY
				stamina_bar.reduce_after_jump()
	
func get_slope_adjusted_speed(horizontal_direction: float) -> float:
	var abs_angle = abs(global_rotation)
	if abs_angle < SLOPE_SLIDE_THRESHOLD or player_location != Location.Ship:
		return SPEED

	var slide_direction = sign(sin(global_rotation))
	var is_uphill = sign(horizontal_direction) != slide_direction

	var t = clampf(
		(abs_angle - SLOPE_SLIDE_THRESHOLD) / (SLOPE_FULL_SLIDE_ANGLE - SLOPE_SLIDE_THRESHOLD),
		0.0, 1.0
	)

	if is_uphill:
		return SPEED * lerpf(1.0, UPHILL_SPEED_PENALTY, t)
	else:
		return SPEED * lerpf(1.0, 1.2, t)

func handle_movement():
	var horizontal_direction := Input.get_axis("move_left", "move_right")
	play_walking_sfx(horizontal_direction)
	if horizontal_direction and not teleporting:
		var effective_speed = get_slope_adjusted_speed(horizontal_direction)
		velocity.x = move_toward(velocity.x, horizontal_direction * effective_speed, SPEED * 0.3)
	else:
		# On slopes: near-zero friction so slide force dominates
		# On flat ground: instant stop (SPEED per frame)
		var decel_rate = SPEED
		if is_on_floor() and player_location == Location.Ship:
			var abs_angle = abs(global_rotation)
			if abs_angle > SLOPE_SLIDE_THRESHOLD:
				decel_rate = 2.0
		velocity.x = move_toward(velocity.x, 0, decel_rate)

	var vertical_direction := Input.get_axis("move_up", "move_down")
	if is_on_ladder:
		if vertical_direction:
			velocity.y = vertical_direction * CLIMBING_SPEED
		else:
			velocity.y = 0
	elif is_on_stairs:
		if vertical_direction:
			player_take_stairs.emit()
	
func handle_sprite_animations():
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
	
func handle_forrest_background():
	if player_location == Location.Forrest:
		forrest_camera.global_position = global_position

func on_ladder():
	is_on_ladder = true

func off_ladder():
	is_on_ladder = false


func on_stairs():
	is_on_stairs = true

func off_stairs():
	is_on_stairs = false

func _on_stairs_area_entered(area: Area2D) -> void:
	on_stairs()

func _on_stairs_area_exited(area: Area2D) -> void:
	off_stairs()

func _on_ladders_area_entered(area: Area2D) -> void:
	on_ladder()

func _on_ladders_area_exited(area: Area2D) -> void:
	off_ladder()

func _on_ladder_area_entered(area: Area2D) -> void:
	on_ladder()

func _on_ladder_area_exited(area: Area2D) -> void:
	off_ladder()
