extends RayCast2D

func _process(delta: float) -> void:
	var target = get_global_mouse_position()
	target_position = target
	
	if is_colliding():
		print(get_collision_point())
