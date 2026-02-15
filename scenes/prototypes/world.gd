extends Node2D


func rotate_self():
	print("klk")
	rotate(2*PI)


func _on_checkpoint_player_walked_through() -> void:
	rotate(-.5)
