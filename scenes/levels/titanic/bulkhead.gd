extends StaticBody2D

func set_all_collision_shapes_enabled(root: Node, enabled: bool) -> void:
	for child in root.get_children():
		if child is CollisionShape2D:
			child.disabled = not enabled
		else:
			set_all_collision_shapes_enabled(child, enabled)
