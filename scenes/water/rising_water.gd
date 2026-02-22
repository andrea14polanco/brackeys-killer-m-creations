extends Node2D

# Offsets from the player's global Y position.
# Viewport is 720px tall, so +360 = bottom edge of screen.
const WATER_OFFSETS: Array[float] = [
	480.0,   # Stage 0: (unused — initial value is current_offset below)
	470.0,   # Stage 1: Checkpoint 1 — barely a hint, player has room to move
	320.0,   # Stage 2: Checkpoint 2 — first real rise, just at screen bottom
	200.0,   # Stage 3: Checkpoint 3 — clearly visible, tension building
	70.0,    # Stage 4: Checkpoint 4 — near player's feet
	-180.0,  # Stage 5: Checkpoint 5 — floods the level
]

const RISE_DURATION := 12.0

var current_stage := 0
var current_offset: float = 480.0
var offset_tween: Tween

func _ready() -> void:
	visible = false
	$WaterBody.monitoring = false

func _physics_process(_delta: float) -> void:
	var player = GameManager.player
	if not player:
		return
	var target_y = player.global_position.y + current_offset
	# Only follow the player upward (to stay on screen).
	# When player moves down (toward the bow/water), water stays put — player can reach it.
	position.y = min(position.y, target_y)

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
		visible = true
		$WaterBody.monitoring = true

	AudioManager.play("WaterAmbient")

	offset_tween = get_tree().create_tween()
	offset_tween.tween_property(self, "current_offset", WATER_OFFSETS[current_stage], RISE_DURATION)\
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)

func _on_water_body_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return
	if body.teleporting:
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
