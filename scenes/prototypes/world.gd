extends Node2D


func rotate_self():
	print("klk")
	rotate(2*PI)


func _on_checkpoint_player_walked_through(angle: float) -> void:
	rotation_degrees = angle


func _on_checkpoint_2_player_walked_through(angle: float) -> void:
	rotation_degrees = angle


func _on_checkpoint_3_player_walked_through(angle: float) -> void:
	rotation_degrees = angle


func _on_checkpoint_4_player_walked_through(angle: float) -> void:
	rotation_degrees = angle
