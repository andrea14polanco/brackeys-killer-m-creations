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

func pan_camera_to_icon():
	var icon := $"../../BookEnd/Icon"
	var cam := self
	var target_icon: Vector2 = icon.global_position
	# Tween 1 — pan to icon
	var tween1 := create_tween()
	tween1.tween_property(cam,"global_position", target_icon, 3.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	await tween1.finished   # ⬅️ Wait here until the camera reaches the icon

	# Tween 2 — pan back to player
	var tween2 := create_tween()
	tween2.tween_property(
		cam, "global_position", $"..".global_position, 3.0
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	await tween2.finished   # Optional: wait for return to finish
