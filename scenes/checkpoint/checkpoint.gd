extends Node2D

signal player_walked_through

@export var has_triggered = false



func _on_static_body_2d_body_exited(body: Node2D) -> void:
	print("Im here")
	if body.is_in_group("player") and !has_triggered:
		player_walked_through.emit()
		has_triggered = true
		
