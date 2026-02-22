extends Control

var tween = null
@onready var settings_flow: Control = $SettingsFlow

func _ready() -> void:
	settings_flow.visible = false

func _on_start_game_button_pressed() -> void:
	AudioManager.play("MenuClick")
	##get_tree().change_scene_to_file("res://scenes/cutscenes/intro_cut_scene.tscn")
	AudioManager.stop("MainMenu")
	AudioManager.play("Cutscene")
	tween = create_tween()
	tween.tween_property($Camera2D, "position", Vector2(1986, 360), 5.0)
	await tween.finished
	$Intro_cut_scene.start_chat()


func _on_settings_button_pressed() -> void:
	settings_flow.visible = true
	AudioManager.play("MenuClick")


func _on_button_pressed() -> void:
	settings_flow.visible = false
	AudioManager.play("MenuClick")


func _on_start_game_button_mouse_entered() -> void:
	AudioManager.play("ButtonHover")


func _on_settings_button_mouse_entered() -> void:
	AudioManager.play("ButtonHover")


func _on_button_mouse_entered() -> void:
	AudioManager.play("ButtonHover")
