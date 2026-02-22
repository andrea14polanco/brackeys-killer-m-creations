extends Node2D

signal player_walked_through(angle)

@export var has_triggered = false
@export var target_angle: float = 0.0

func _on_static_body_2d_body_exited(body: Node2D) -> void:
	if body.is_in_group("player") and !has_triggered:
		player_walked_through.emit(target_angle)
		has_triggered = true


func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player") and !has_triggered:
		player_walked_through.emit(target_angle)
		has_triggered = true
		$"../..".close_bulkheads()


func _on_body_shape_exited(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	pass # Replace with function body.
