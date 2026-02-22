extends StaticBody2D


@onready var col: CollisionObject2D = $StairCol
@onready var detection_area: Area2D = $DetectionZone

const LIMIT_DEGREES = 25

var player_nearby: bool = false
var player_using_stair: bool = false
var is_flat: bool = false


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	col.disabled = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if is_flat:
		return
		
	var player:CharacterBody2D = GameManager.player
	
	if player == null:
		return
	
	if player.is_on_ladder:
		return


func _on_detection_zone_body_entered(body: Node2D) -> void:
	pass # Replace with function body.


func _on_detection_zone_body_exited(body: Node2D) -> void:
	pass # Replace with function body.
