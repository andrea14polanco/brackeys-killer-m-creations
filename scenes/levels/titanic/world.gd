extends Node2D

var bulkhead_num = 0
var rotation_tween: Tween
@onready var rising_water = $"../RisingWater"

func _ready() -> void:
	GameManager.titanic = self
	if GameManager.player:
		GameManager.player.set_physics_process(false)
	AudioManager.stop("MainMenu")
	AudioManager.stop("Cutscene")
	AudioManager.play("TitanicMusic")
	$Player/Text_Panel.show()
	next_chat(1)


func _on_checkpoint_reached(angle: Variant) -> void:
	rotate_smoothly(angle)
	rising_water.raise_water()

func _on_checkpoint_player_walked_through(angle: Variant) -> void:
	_on_checkpoint_reached(angle)

func _on_checkpoint_2_player_walked_through(angle: Variant) -> void:
	_on_checkpoint_reached(angle)

func _on_checkpoint_3_player_walked_through(angle: Variant) -> void:
	_on_checkpoint_reached(angle)

func _on_checkpoint_4_player_walked_through(angle: Variant) -> void:
	_on_checkpoint_reached(angle)

func _on_checkpoint_5_player_walked_through(angle: Variant) -> void:
	_on_checkpoint_reached(angle)

func rotate_smoothly(angle):
	if rotation_tween and rotation_tween.is_valid():
		rotation_tween.kill()
	rotation_tween = get_tree().create_tween()
	rotation_tween.tween_property($".", "rotation_degrees", angle, 10.0)\
		.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)

func next_chat(num):
	if GameManager.started == false:
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
			await $Player/Camera2D.shake_once()
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
			GameManager.started = true
			$Player/Text_Panel._panel_chat("Player",
			["'Hey! NO! WAIT DONT LEAVE ME!'"]
			,"close_chat"
			,7
			)
	else:
		if num == 1:
			var random_text = ["Looks like you are struggling.",
			"Starting over again?",
			"Books can be challenging."
			,"I once reread a book 100 times."]
			var random_num = randi_range(0,3)
			$Player/Text_Panel._panel_chat("Mysterious Person",
			[random_text[random_num]]
			,"close_chat"
			,2
			)

func close_chat():
	$Player/Text_Panel.hide()
	$Player/Reset_Button.show()
	GameManager.player.set_physics_process(true)

func close_bulkheads():
	AudioManager.play("MetalDoorClosing")
	bulkhead_num += 1
	if bulkhead_num == 1:
		$Deck1/BulkHeads.show()
		$Deck1/BulkHeads/StaticBody2D.set_all_collision_shapes_enabled(true)
	if bulkhead_num == 2:
		$Deck2/BulkHeads.show()
		$Deck2/BulkHeads/StaticBody2D.set_all_collision_shapes_enabled(true)
	if bulkhead_num == 3:
		$Deck3/BulkHeads.show()
		$Deck3/BulkHeads/StaticBody2D.set_all_collision_shapes_enabled(true)

func reload_level():
	GameManager.reset_level_state()
	get_tree().reload_current_scene()


func _on_reset_button_pressed() -> void:
	AudioManager.play("PageTurning")
	reload_level()
