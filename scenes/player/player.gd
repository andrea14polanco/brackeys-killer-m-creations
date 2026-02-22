extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -400.0
const CLIMBING_SPEED = 100
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
var gravity: Vector2 = Vector2(0.0, 980.0)
var facing_right = true
var teleporting = false
var is_moving = true
var player_location: Location = Location.Ship
var current_sfx_name: String = ""
var current_bgm_name: String = ""

func _ready() -> void:
	GameManager.player = self
	original_material = animated_sprite_2d.material
	animated_sprite_2d.material = null
	current_sfx_name = ""
	current_bgm_name = ""
	

func _physics_process(delta: float) -> void:
	play_bgm()
	handle_gravity(delta)
	handle_jump()
	handle_movement()
	move_and_slide()
	handle_sprite_animations()
	handle_forrest_background()
	

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
		if not AudioManager.is_audio_playing(current_sfx_name):
			AudioManager.play(current_sfx_name)
		else:
			AudioManager.pause(current_sfx_name, false)
	else:
		if AudioManager.is_audio_playing(current_sfx_name):
			AudioManager.pause(current_sfx_name, true)
	
func play_bgm():
	var new_music_name = ""
	
	if player_location == Location.Ship:
		new_music_name = "TitanicMusic"
	elif player_location == Location.Forrest:
		new_music_name = "Forest"
	print(new_music_name)
	if current_bgm_name != new_music_name and current_bgm_name != "":
		AudioManager.stop(current_bgm_name)
	
	current_bgm_name = new_music_name
	if not AudioManager.is_audio_playing(current_bgm_name):
		AudioManager.play(current_bgm_name)
	
func handle_gravity(delta):
	if not is_on_floor() and not is_on_ladder:
		velocity += get_gravity() * delta
		is_jumping = true
	
func handle_jump():
	if is_on_floor():
		is_jumping = false
		if stamina_bar.value > 1 and Input.is_action_just_pressed("jump"):
				is_jumping = false
				velocity.y = JUMP_VELOCITY
				stamina_bar.reduce_after_jump()
	
func handle_movement():
	var horizontal_direction := Input.get_axis("move_left", "move_right")
	play_walking_sfx(horizontal_direction)
	if horizontal_direction and not teleporting:
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

func _on_stairs_area_entered(area: Area2D) -> void:
	is_on_ladder = true
	
func _on_stairs_area_exited(area: Area2D) -> void:
	is_on_ladder = false
	gravity = get_gravity()
