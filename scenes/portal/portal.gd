extends Area2D

enum Location {
	Forrest,
	Ship
}
@export var next_portal_marker: Marker2D
@export var can_teleport: bool
@export var next_portal_location: Location = Location.Ship

var is_portal_used = false


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and can_teleport and not is_portal_used:
		is_portal_used = true
		await body.start_teleport()
		AudioManager.play("Portal")
		body.global_position = next_portal_marker.global_position
		body.player_location = next_portal_location
		body.stop_teleport()
		# Allow reuse after player has moved away
		await get_tree().create_timer(1.0).timeout
		is_portal_used = false
