extends Camera2D

func _process(delta: float) -> void:
	position = GameManager.player.global_position
