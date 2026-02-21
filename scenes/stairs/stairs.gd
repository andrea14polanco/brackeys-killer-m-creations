extends StaticBody2D

@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
var is_player_on_stairs

func _ready() -> void:
	pass#collision_shape_2d.set_deferred("disabled", true)

func _physics_process(delta: float) -> void:
	pass
		


func _on_player_player_take_stairs() -> void:
	is_player_on_stairs = true
	collision_shape_2d.set_deferred("disabled", false)

func _on_player_in_stairs_area_detector_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		body.is_on_stairs = true
		collision_shape_2d.set_deferred("disabled", true)


func _on_player_at_stairs_down_area_detector_body_exited(body: Node2D) -> void:
	if not is_player_on_stairs:
		print("KLK")
		collision_shape_2d.set_deferred("disabled", true)
		is_player_on_stairs = false


func _on_player_at_stairs_up_area_detector_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		body.is_on_stairs = true
		collision_shape_2d.set_deferred("disabled", false)
