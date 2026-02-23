extends Control

var tween = null

func _ready() -> void:
	AudioManager.stop("MainMenu")
	AudioManager.stop("TitanicMusic")
	AudioManager.play("Cutscene")
	$Intro_cut_scene.start_chat2()

func close_chat():
	$Intro_cut_scene.hide()
	tween = create_tween()
	tween.tween_property($bg_Panel, "position", Vector2(90, -2020), 30.0)
	await tween.finished
	get_tree().change_scene_to_file("res://scenes/mainmenu/main_menu.tscn")
