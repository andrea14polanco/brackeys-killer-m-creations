extends ProgressBar

signal stamina_depleted
signal stamina_regenerated

var current_stamina: float = 0.0
var stamina_factor: float = .8
var max_stamina: float = 100.0
var is_draining = false


func _ready() -> void:
	value =  max_stamina
	current_stamina =  max_stamina


func _process(delta: float) -> void:
	regenarate_stamina(delta)
	
func regenarate_stamina(delta):
	if  value < max_stamina and !is_draining:
		value+=delta*stamina_factor
	
func reduce_after_jump():
	is_draining = true
	reduction_anim(value)

func reduction_anim(value):
	var tween = get_tree().create_tween()
	tween.tween_property($".", "value", value-25, 1.0)
	is_draining = false
	
