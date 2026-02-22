extends Node2D

# Offsets from the player's global Y position.
# Viewport is 720px tall, so +360 = bottom edge of screen.
const WATER_OFFSETS: Array[float] = [
	600.0,   # Stage 0: initial — hidden below viewport
	500.0,   # Stage 1: CP1 (-15°) — barely peeking at bottom
	380.0,   # Stage 2: CP2 (-30°) — just visible at screen edge
	280.0,   # Stage 3: CP3 (-50°) — visible, tension building
	160.0,   # Stage 4: CP4 (-65°) — lower third, real pressure
	-200.0,  # Stage 5: CP5 (-90°) — full flood, endgame
]

const RISE_DURATIONS: Array[float] = [
	0.0,    # Stage 0: unused
	15.0,   # Stage 1: gentle intro
	15.0,   # Stage 2: player still has good speed
	18.0,   # Stage 3: steep angle, big rotation Y-shift
	25.0,   # Stage 4: slowest player speed + longest segment
	10.0,   # Stage 5: fast dramatic endgame flood
]

const WAVE_HEIGHTS: Array[float] = [0.015, 0.018, 0.022, 0.028, 0.035, 0.045]
const WAVE_SPEEDS: Array[float]  = [1.5,   1.8,   2.2,   2.8,   3.5,   4.5]

var current_stage := 0
var current_offset: float = 600.0
var offset_tween: Tween
var proximity_cooldown: float = 0.0

func _ready() -> void:
	visible = false
	$WaterBody.monitoring = false

func _physics_process(delta: float) -> void:
	var player = GameManager.player
	if not player:
		return
	if player.player_location != player.Location.Ship:
		return
	var target_y = player.global_position.y + current_offset
	position.y = min(position.y, target_y)

	if not visible:
		return

	# Proximity shake — subtle rumble when water is within 200px of player
	proximity_cooldown -= delta
	var distance_to_player = position.y - player.global_position.y
	if distance_to_player < 200.0 and distance_to_player > -50.0:
		if proximity_cooldown <= 0.0:
			proximity_cooldown = 1.5
			var camera = player.get_node_or_null("Camera2D")
			if camera and camera.has_method("shake_once"):
				camera.shake_once(4.0, 0.1)

func raise_water() -> void:
	current_stage += 1
	if current_stage >= WATER_OFFSETS.size():
		return

	if offset_tween and offset_tween.is_valid():
		offset_tween.kill()

	# Snap into position on first raise so the water doesn't jump from (0,0)
	if not visible:
		var player = GameManager.player
		if player:
			position.y = player.global_position.y + current_offset
			var camera = player.get_node_or_null("Camera2D")
			if camera and camera.has_method("shake_once"):
				camera.shake_once(15.0, 0.25)
		visible = true
		$WaterBody.monitoring = true

	AudioManager.play("WaterAmbient")

	offset_tween = get_tree().create_tween()
	var duration = RISE_DURATIONS[current_stage]
	offset_tween.tween_property(self, "current_offset", WATER_OFFSETS[current_stage], duration)\
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)

	# Escalate wave shader params to make water look more violent each stage
	var mat = $WaterVisual.material as ShaderMaterial
	if mat:
		var wave_tween = get_tree().create_tween()
		wave_tween.set_parallel(true)
		wave_tween.tween_method(
			func(v): mat.set_shader_parameter("wave_height", v),
			mat.get_shader_parameter("wave_height"),
			WAVE_HEIGHTS[current_stage],
			duration * 0.5
		)
		wave_tween.tween_method(
			func(v): mat.set_shader_parameter("wave_speed", v),
			mat.get_shader_parameter("wave_speed"),
			WAVE_SPEEDS[current_stage],
			duration * 0.5
		)

func _on_water_body_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return
	if body.teleporting:
		return
	if body.player_location != body.Location.Ship:
		return

	# Drowning sound + camera shake then reload
	AudioManager.stop("WaterAmbient")
	AudioManager.play("WaterDrown")
	var camera = body.get_node_or_null("Camera2D")
	if camera and camera.has_method("shake_once"):
		camera.shake_once(30.0, 0.4)
		await get_tree().create_timer(0.5).timeout

	var world = get_node_or_null("../World")
	if world and world.has_method("reload_level"):
		world.reload_level()
