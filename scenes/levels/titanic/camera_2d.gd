extends Camera2D

func shake_once(amount := 20.0, duration := 0.2):
	var original_offset := offset
	var timer := 0.0
	#
	while timer < duration:
		offset = Vector2(
		randf_range(-amount, amount),
			randf_range(-amount, amount)
		)
		await get_tree().process_frame
		timer += get_process_delta_time()
	offset = original_offset
