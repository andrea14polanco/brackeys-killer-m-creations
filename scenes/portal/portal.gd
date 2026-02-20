extends Area2D

@export var self_portal_position: Vector2 = Vector2(0,0)
@export var next_portal_position: Vector2 = Vector2(0,0)
var is_portal_used = false
var is_
func _ready() -> void:
	self_portal_position = global_position


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_body_entered(body: Node2D) -> void:
	#if !is_portal_used:
	teleport(body)
		#is_portal_used = true

func teleport(body: Node2D):
	print("player position before teleport")
	print(body.global_position)
	print(next_portal_position)
	body.global_position = next_portal_position
	print("player position after teleport")
	print(body.global_position)
