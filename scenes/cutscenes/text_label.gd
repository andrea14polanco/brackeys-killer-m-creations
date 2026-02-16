extends Label

@export var full_text: String = ""
@export var char_delay: float = 0.03  # seconds per character

signal typing_finished

var typing := false
var stop_typing := false

func type_text() -> void:
	# If something is already typing, stop it
	if typing:
		stop_typing = true
		await typing_finished  # custom signal (below)
		#
	typing = true
	stop_typing = false
	text = ""
	#
	for i in full_text.length():
		if stop_typing:
			break  # exit the loop immediately
		text = full_text.substr(0, i + 1)
		await get_tree().create_timer(char_delay).timeout
		#
	typing = false
	emit_signal("typing_finished")
