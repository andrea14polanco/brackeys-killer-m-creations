extends Node

func _ready() -> void:
	play("MainMenu")

func play(sound_name):
	var player = get_node(sound_name)
	if not player.is_playing():
		player.play()

func stop(sound_name):
	get_node(sound_name).stop()

func pause(sound_name, flag):
	get_node(sound_name).set_stream_paused(flag)

func is_audio_playing(sound_name):
	return get_node(sound_name).is_playing()
