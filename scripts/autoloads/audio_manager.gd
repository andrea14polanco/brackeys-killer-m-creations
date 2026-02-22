extends Node

func _ready() -> void:
	play("MainMenu")

func play(sound_name):
	get_node(sound_name).play()

func stop(sound_name):
	get_node(sound_name).stop()

func pause(sound_name, flag):
	get_node(sound_name).set_stream_paused(flag)

func is_audio_playing(sound_name):
	return get_node(sound_name).is_playing()
