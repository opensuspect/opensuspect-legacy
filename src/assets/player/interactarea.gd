extends Area2D

var overlappingPoints: Array = []

func updateOverlapping():
	var overlapping = []
	for i in get_overlapping_bodies():
		if i.is_in_group("interactpoints") and raycast(i.global_position) == i:
			overlapping.append(i)
	print("overlapping bodies: ", overlapping)

func raycast(to: Vector2):
	$RayCast2D.cast_to = $RayCast2D.to_local(to)
	$RayCast2D.force_raycast_update()
	var result = $RayCast2D.get_collider()
	print(result)
	return result

func _on_interactarea_body_entered(body):
	updateOverlapping()

func _on_interactarea_body_exited(body):
	pass # Replace with function body.
