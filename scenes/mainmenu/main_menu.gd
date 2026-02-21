extends Control

var tween = null

func _on_start_game_button_pressed() -> void:
	##get_tree().change_scene_to_file("res://scenes/cutscenes/intro_cut_scene.tscn")
	tween = create_tween()
	tween.tween_property($Camera2D, "position", Vector2(1986, 360), 5.0)
	await tween.finished
	$Intro_cut_scene.start_chat()
