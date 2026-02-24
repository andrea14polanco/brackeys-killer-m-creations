extends Node

func _ready() -> void:
	play("MainMenu")

func play(sound_name):
	if sound_name == "":
		return
	var node = get_node_or_null(sound_name)
	if node and not node.is_playing():
		node.play()

func stop(sound_name):
	if sound_name == "":
		return
	var node = get_node_or_null(sound_name)
	if node:
		node.stop()

func pause(sound_name, flag):
	if sound_name == "":
		return
	var node = get_node_or_null(sound_name)
	if node:
		node.set_stream_paused(flag)

func is_audio_playing(sound_name):
	if sound_name == "":
		return false
	var node = get_node_or_null(sound_name)
	if node:
		return node.is_playing()
	return false

func set_pitch(sound_name: String, pitch: float) -> void:
	var node = get_node_or_null(sound_name)
	if node:
		node.pitch_scale = pitch

func set_volume(sound_name: String, db: float) -> void:
	var node = get_node_or_null(sound_name)
	if node:
		node.volume_db = db
