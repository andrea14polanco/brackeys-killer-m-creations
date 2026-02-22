extends ProgressBar

signal stamina_depleted
signal stamina_regenerated

var max_stamina: float = 100.0
var stamina_regen_rate: float = 15.0      # points per second
var jump_cost: float = 25.0               # stamina lost per jump
var regen_delay: float = 1.5              # seconds before regen starts
var drain_duration: float = 0.4           # how fast the bar animates down

var is_draining: bool = false
var regen_timer: float = 0.0

func _ready() -> void:
	max_value = max_stamina
	value = max_stamina

func _process(delta: float) -> void:
	if regen_timer > 0.0:
		regen_timer -= delta
		return

	if not is_draining and value < max_stamina:
		value += delta * stamina_regen_rate
		value = min(value, max_stamina)
		if value >= max_stamina:
			stamina_regenerated.emit()

func reduce_after_jump() -> void:
	if is_draining:
		return
	is_draining = true
	var target = max(value - jump_cost, 0.0)
	var tween = create_tween()
	tween.tween_property(self, "value", target, drain_duration)
	await tween.finished
	is_draining = false
	regen_timer = regen_delay
	if value <= 0.0:
		stamina_depleted.emit()
