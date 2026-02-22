extends StaticBody2D

func set_all_collision_shapes_enabled(enabled: bool) -> void:
	var root = self
	for child in root.get_children():
		if child is CollisionShape2D:
			child.set_deferred("disabled", not enabled)
		elif child.has_method("set_all_collision_shapes_enabled"):
			child.set_all_collision_shapes_enabled(enabled)
