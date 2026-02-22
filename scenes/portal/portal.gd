extends Area2D

#@export var self_portal_position: Vector2 = Vector2(0,0)
#@export var next_portal_position: Vector2 = Vector2(0,0)
#@export var next_portal: Area2D
enum Location {
	Forrest,
	Ship
}
@export var next_portal_marker: Marker2D
@export var can_teleport: bool
@export var next_portal_location: Location = Location.Ship

var is_portal_used = false


func _ready() -> void:
	pass # self_portal_position = global_position


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		if can_teleport:
			await body.start_teleport()
			teleport(body)
			body.stop_teleport()
			body.teleporting = false
			is_portal_used = true
			
			


func teleport(body: Node2D):
	if not is_portal_used:
		AudioManager.play("Portal")
		is_portal_used = true 
		body.global_position = next_portal_marker.global_position
		print(next_portal_location)
		body.player_location = next_portal_location
		
	
