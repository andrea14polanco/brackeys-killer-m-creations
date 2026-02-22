extends Label

@export var full_text: String = ""
@export var char_delay: float = 0.03  # seconds per character

var _gen := 0
var is_typing := false

func type_text() -> void:
	_gen += 1
	var my_gen := _gen
	is_typing = true
	text = ""
	for i in full_text.length():
		if _gen != my_gen or not is_inside_tree():
			is_typing = false
			return
		text = full_text.substr(0, i + 1)
		await get_tree().create_timer(char_delay).timeout
	is_typing = false

func finish() -> void:
	_gen += 1        # invalidates the running coroutine on its next check
	is_typing = false
	text = full_text  # snap to complete text immediately
