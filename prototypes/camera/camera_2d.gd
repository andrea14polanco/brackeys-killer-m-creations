extends Camera2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func rotate_smoothly(angle):
	var tween = get_tree().create_tween()
	tween.tween_property($".", "rotation_degrees", angle, 1.0)
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_checkpoint_player_walked_through(angle: Variant) -> void:
	rotate_smoothly(-angle)
	pass # Replace with function body.


func _on_checkpoint_2_player_walked_through(angle: Variant) -> void:
	rotate_smoothly(-angle)


func _on_checkpoint_3_player_walked_through(angle: Variant) -> void:
	rotate_smoothly(-angle)


func _on_checkpoint_4_player_walked_through(angle: Variant) -> void:
	rotate_smoothly(-angle)
