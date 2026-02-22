extends Node2D

func _ready() -> void:
	GameManager.titanic = self
	GameManager.player.set_physics_process(false)
	AudioManager.stop("MainMenu")
	AudioManager.stop("Cutscene")
	AudioManager.play("TitanicMusic")
	$Player/Text_Panel.show()
	next_chat(1)


func _on_checkpoint_2_player_walked_through(angle: Variant) -> void:
	rotate_smoothly(angle)


func _on_checkpoint_3_player_walked_through(angle: Variant) -> void:
	rotate_smoothly(angle)


func _on_checkpoint_4_player_walked_through(angle: Variant) -> void:
	rotate_smoothly(angle)

func rotate_smoothly(angle):
	var tween = get_tree().create_tween()
	tween.tween_property($".", "rotation_degrees", angle, 10.0)
	

func _on_checkpoint_player_walked_through(angle: Variant) -> void:
	#AudioManager.play("MainMenu")
	rotate_smoothly(angle)

func next_chat(num):
	if num == 1:
		$Player/Text_Panel._panel_chat("Player",
		["'Woah where are we?'"]
		,"next_chat2"
		,2
		)
	elif num == 2:
		$Player/Text_Panel._panel_chat("Mysterious Person",
		["'You are on the titanic, I suppose a much more interactive environment would be helpful 
		for such... minds.'"]
		,"next_chat2"
		,3
		)
	elif num == 3:
		$Player/Text_Panel._panel_chat("Player",
		["'Yea hahaha! This is way better than...'"]
		,"next_chat2"
		,4
		)
	elif num == 4:
		$Player/Camera2D.shake_once()
		$Player/Text_Panel._panel_chat("Player",
		["'!!!????!!!! What was that?'"]
		,"next_chat2"
		,5
		)
	elif num == 5:
		$Player/Text_Panel._panel_chat("Mysterious Person",
		["'Oh that? It's the exciting part! Also I added a surprise from your other book too!'", "'Well I should let you be now.'"]
		,"next_chat2"
		,6
		)
	elif num == 6:
		$Player/Text_Panel._panel_chat("Player",
		["'Hey! NO! WAIT DONT LEAVE ME!'"]
		,"close_chat"
		,7
		)

func close_chat():
	$Player/Text_Panel.hide()
	GameManager.player.set_physics_process(true)
