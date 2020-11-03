extends Area2D

var overlappingPoints: Array = []

func updateInteraction():
	print("overlapping bodies: ", overlappingPoints)

func raycast(to: Vector2):
	$RayCast2D.cast_to = $RayCast2D.to_local(to)
	$RayCast2D.force_raycast_update()
	var result = $RayCast2D.get_collider()
	return result

func _on_interactarea_body_entered(_body):
	print(_body, " entered")
	if _body.is_in_group("interactpoints") and raycast(_body.global_position) == _body:
		overlappingPoints.append(_body)
	updateInteraction()

func _on_interactarea_body_exited(_body):
	print(_body, " exited")
	overlappingPoints.erase(_body)
	updateInteraction()
