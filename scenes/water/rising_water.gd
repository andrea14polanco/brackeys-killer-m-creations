extends Node2D

# Water checkpoint X-positions in SHIP-LOCAL space (player.position.x).
# Each threshold triggers advancement to the next water stage.
# Staggered between rotation CPs for pacing variety.
const WATER_CP_X: Array[float] = [
	3500.0,   # → Stage 1: water appears (between RotCP1 and RotCP2)
	8500.0,   # → Stage 2: between RotCP2 and RotCP3
	14000.0,  # → Stage 3: between RotCP3 and RotCP4
	22000.0,  # → Stage 4: between RotCP4 and RotCP5
	29000.0,  # → Stage 5: past final RotCP — endgame flood
]

# Base Y-offset from player at each water stage.
# Positive = below player (safe), negative = above player (flood).
const WATER_OFFSETS: Array[float] = [
	700.0,   # Stage 0: hidden below viewport
	550.0,   # Stage 1: barely peeking
	400.0,   # Stage 2: visible at screen edge
	280.0,   # Stage 3: tension building
	140.0,   # Stage 4: real pressure
	-200.0,  # Stage 5: full flood, endgame
]

const RISE_DURATIONS: Array[float] = [
	0.0,   # Stage 0: unused
	8.0,   # Stage 1: moderate surge
	8.0,   # Stage 2
	10.0,  # Stage 3
	12.0,  # Stage 4
	6.0,   # Stage 5: fast endgame
]

const WAVE_HEIGHTS: Array[float] = [0.015, 0.018, 0.022, 0.028, 0.035, 0.045]
const WAVE_SPEEDS: Array[float]  = [1.5,   1.8,   2.2,   2.8,   3.5,   4.5]

# Time-based creep: px/sec the water rises per stage (the core threat).
# Escalates so later stages feel like real panic.
const TIME_CREEP_RATES: Array[float] = [
	0.0,   # Stage 0: water not visible yet
	3.0,   # Stage 1: gentle intro, learn the mechanic
	5.0,   # Stage 2: noticeable pressure
	8.0,   # Stage 3: building urgency
	12.0,  # Stage 4: real danger
	20.0,  # Stage 5: panic mode
]

# Grace period: water slows when very close, one last chance per stage.
const GRACE_DISTANCE: float = 80.0
const GRACE_DURATION: float = 4.0
const GRACE_CREEP_MULT: float = 0.15  # 15% speed during grace

# Music pitch per stage — subtle escalation
const MUSIC_PITCH: Array[float] = [1.0, 1.0, 1.02, 1.04, 1.07, 1.12]

var current_stage := 0
var current_offset: float = 700.0
var offset_tween: Tween
var proximity_cooldown: float = 0.0
var max_local_x: float = -INF    # For checkpoint detection only
var time_creep: float = 0.0      # Accumulated time-based rise
var grace_active: bool = false
var grace_timer: float = 0.0
var grace_used_at_stage: int = -1  # Which stage grace was last used
var grace_was_active: bool = false  # Track edge for audio trigger

# Vignette overlay references
var vignette_rect: ColorRect
var vignette_material: ShaderMaterial
var fade_rect: ColorRect
var vignette_pulse_time: float = 0.0

func _ready() -> void:
	visible = false
	$WaterBody.monitoring = false
	_create_overlay()

func _create_overlay() -> void:
	var canvas_layer = CanvasLayer.new()
	canvas_layer.layer = 100
	add_child(canvas_layer)

	# Vignette overlay
	vignette_rect = ColorRect.new()
	vignette_rect.anchors_preset = Control.PRESET_FULL_RECT
	vignette_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var shader = load("res://scenes/water/vignette.gdshader") as Shader
	vignette_material = ShaderMaterial.new()
	vignette_material.shader = shader
	vignette_material.set_shader_parameter("intensity", 0.0)
	vignette_material.set_shader_parameter("tint", Color.BLACK)
	vignette_rect.material = vignette_material
	canvas_layer.add_child(vignette_rect)

	# Death fade overlay (solid black, starts invisible)
	fade_rect = ColorRect.new()
	fade_rect.anchors_preset = Control.PRESET_FULL_RECT
	fade_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	fade_rect.color = Color(0, 0, 0, 0)
	canvas_layer.add_child(fade_rect)

func _physics_process(delta: float) -> void:
	var player = GameManager.player
	if not player:
		return
	if player.player_location != player.Location.Ship:
		return

	var local_x = player.position.x  # Ship-local, rotation-immune

	# Initialize max on first frame
	if max_local_x == -INF:
		max_local_x = local_x

	# Track max forward position for checkpoint detection
	if local_x > max_local_x:
		max_local_x = local_x

	# Auto-detect water checkpoint crossings
	_check_water_checkpoints(max_local_x)

	# Time-based creep: water rises on its own — the core threat
	if visible:
		var creep_rate = TIME_CREEP_RATES[current_stage]
		var distance_to_player = position.y - player.global_position.y

		# Grace period: slow water when it's at your feet (one chance per stage)
		if not grace_active and grace_used_at_stage < current_stage:
			if distance_to_player < GRACE_DISTANCE and distance_to_player > -10.0:
				grace_active = true
				grace_timer = GRACE_DURATION
				grace_used_at_stage = current_stage

		if grace_active:
			creep_rate *= GRACE_CREEP_MULT
			grace_timer -= delta
			if grace_timer <= 0.0:
				grace_active = false

		time_creep += creep_rate * delta

	# Combine stage offset with time-based creep
	var effective_offset = current_offset - time_creep
	var target_y = player.global_position.y + effective_offset
	position.y = min(position.y, target_y)

	if not visible:
		return

	# --- Grace audio edge detection ---
	if grace_active and not grace_was_active:
		# Grace just activated — play alarm (MetalDoorClosing at high pitch as fallback)
		AudioManager.set_pitch("MetalDoorClosing", 2.0)
		AudioManager.play("MetalDoorClosing")
	if not grace_active and grace_was_active:
		# Grace just expired — stop alarm
		AudioManager.stop("MetalDoorClosing")
		AudioManager.set_pitch("MetalDoorClosing", 1.0)
	grace_was_active = grace_active

	# --- Proximity-based effects ---
	var dist = position.y - player.global_position.y

	# Vignette intensity
	_update_vignette(dist, delta)

	# Audio urgency: WaterAmbient pitch modulation
	_update_audio_urgency(dist)

	# Proximity shake — more intense during grace (water is RIGHT THERE)
	proximity_cooldown -= delta
	if dist < 200.0 and dist > -50.0:
		var shake_interval = 0.5 if grace_active else 1.5
		var shake_amount = 8.0 if grace_active else 4.0
		if proximity_cooldown <= 0.0:
			proximity_cooldown = shake_interval
			var camera = player.get_node_or_null("Camera2D")
			if camera and camera.has_method("shake_once"):
				camera.shake_once(shake_amount, 0.1)

func _update_vignette(dist: float, delta: float) -> void:
	if not vignette_material:
		return

	var target_intensity: float = 0.0
	var tint := Color.BLACK

	if grace_active:
		# Pulsing red vignette during grace
		vignette_pulse_time += delta * 4.0
		target_intensity = lerp(0.4, 0.8, (sin(vignette_pulse_time) + 1.0) * 0.5)
		tint = Color(0.6, 0.0, 0.0)
	elif dist < 200.0 and dist > -50.0:
		# Proximity-based: ramp from 0 at 200px to 0.5 at 50px
		var t = clamp(inverse_lerp(200.0, 50.0, dist), 0.0, 1.0)
		target_intensity = t * 0.5
		# Slight red shift as danger increases
		tint = Color.BLACK.lerp(Color(0.3, 0.0, 0.0), t)
	else:
		vignette_pulse_time = 0.0

	vignette_material.set_shader_parameter("intensity", target_intensity)
	vignette_material.set_shader_parameter("tint", tint)

func _update_audio_urgency(dist: float) -> void:
	if dist < 200.0 and dist > -50.0:
		# Pitch ramps from 1.0 at 200px to 1.5 at 80px
		var t = clamp(inverse_lerp(200.0, 80.0, dist), 0.0, 1.0)
		var pitch = lerp(1.0, 1.5, t)
		if grace_active:
			pitch = 2.0
		AudioManager.set_pitch("WaterAmbient", pitch)
	else:
		AudioManager.set_pitch("WaterAmbient", 1.0)

func _check_water_checkpoints(local_x: float) -> void:
	if current_stage >= WATER_CP_X.size():
		return
	if local_x < WATER_CP_X[current_stage]:
		return
	_advance_water_stage()

func _advance_water_stage() -> void:
	current_stage += 1
	if current_stage >= WATER_OFFSETS.size():
		return

	if offset_tween and offset_tween.is_valid():
		offset_tween.kill()

	# First stage: make water visible with dramatic entrance
	if not visible:
		var player = GameManager.player
		if player:
			var effective_offset = current_offset - time_creep
			position.y = player.global_position.y + effective_offset
			var camera = player.get_node_or_null("Camera2D")
			if camera and camera.has_method("shake_once"):
				camera.shake_once(15.0, 0.25)
		visible = true
		$WaterBody.monitoring = true
	else:
		# Camera shake on subsequent water surges
		var player = GameManager.player
		if player:
			var camera = player.get_node_or_null("Camera2D")
			if camera and camera.has_method("shake_once"):
				camera.shake_once(10.0, 0.2)

	AudioManager.play("WaterAmbient")

	# Music intensity: escalate pitch per stage
	AudioManager.set_pitch("TitanicMusic", MUSIC_PITCH[current_stage])
	# Lower music volume at high stages so SFX punch through
	if current_stage >= 3:
		var vol_reduction = (current_stage - 2) * -2.0  # -2, -4, -6 dB
		AudioManager.set_volume("TitanicMusic", vol_reduction)

	# Tween the stage offset down (discrete surge)
	offset_tween = get_tree().create_tween()
	var duration = RISE_DURATIONS[current_stage]
	offset_tween.tween_property(self, "current_offset", WATER_OFFSETS[current_stage], duration)\
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)

	# Escalate wave shader params to make water more violent each stage
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

	AudioManager.stop("WaterAmbient")
	AudioManager.stop("MetalDoorClosing")
	AudioManager.set_pitch("WaterAmbient", 1.0)
	AudioManager.set_pitch("MetalDoorClosing", 1.0)
	AudioManager.set_pitch("TitanicMusic", 1.0)
	AudioManager.set_volume("TitanicMusic", 0.0)
	AudioManager.play("WaterDrown")

	# Clear vignette
	if vignette_material:
		vignette_material.set_shader_parameter("intensity", 0.0)

	var camera = body.get_node_or_null("Camera2D")
	if camera and camera.has_method("shake_once"):
		camera.shake_once(30.0, 0.4)

	# Fade to black before reload
	if fade_rect:
		var fade_tween = get_tree().create_tween()
		fade_tween.tween_property(fade_rect, "color:a", 1.0, 0.4)\
			.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_SINE)
		await fade_tween.finished
	else:
		await get_tree().create_timer(0.5).timeout

	var world = get_node_or_null("../World")
	if world and world.has_method("reload_level"):
		world.reload_level()
