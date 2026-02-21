extends Area2D

#@export var self_portal_position: Vector2 = Vector2(0,0)
#@export var next_portal_position: Vector2 = Vector2(0,0)
#@export var next_portal: Area2D
@export var next_portal_marker: Marker2D
@export var can_teleport: bool

var is_portal_used = false


func _ready() -> void:
	pass # self_portal_position = global_position


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_body_entered(body: Node2D) -> void:
	if can_teleport:
		teleport(body)
		is_portal_used = true


func teleport(body: Node2D):
	if not is_portal_used:
		is_portal_used = true 
		body.global_position = next_portal_marker.global_position
	
