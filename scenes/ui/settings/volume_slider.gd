extends HSlider

@export var bus_name: String
var bus_index: int

func _ready() -> void:
	bus_index = AudioServer.get_bus_index(bus_name)
	if bus_index == -1:
		push_warning("Audio bus '%s' not found!" % bus_name)
		return
	value_changed.connect(_on_value_changed)
	value = db_to_linear(AudioServer.get_bus_volume_db(bus_index))



func _on_value_changed(value: float) -> void:
	
	if not AudioManager.is_audio_playing("VolumeSlider"):
		AudioManager.play("VolumeSlider")
	if bus_index == -1:
		return
	AudioServer.set_bus_volume_db(bus_index, linear_to_db(value))
