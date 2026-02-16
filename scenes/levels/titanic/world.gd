extends Node2D



func _on_checkpoint_player_walked_through(angle: Variant) -> void:
	rotate_smoothly(angle)


func _on_checkpoint_2_player_walked_through(angle: Variant) -> void:
	rotate_smoothly(angle)


func _on_checkpoint_3_player_walked_through(angle: Variant) -> void:
	rotate_smoothly(angle)


func _on_checkpoint_4_player_walked_through(angle: Variant) -> void:
	rotate_smoothly(angle)

func rotate_smoothly(angle):
	var tween = get_tree().create_tween()
	tween.tween_property($".", "rotation_degrees", angle, 1.0)
	
