extends Area2D

var overlappingPoints: Array = []

var pointsData: Dictionary = {}

func updateInteraction():
	#print("overlapping bodies: ", overlappingPoints)
	#print(pointsData)
	if UIManager.get_interact_ui_node() == null:
		return
	if not get_parent().main_player:
		return
	UIManager.get_interact_ui_node().receiveInteractData(pointsData)

func raycast(to: Vector2):
	$RayCast2D.cast_to = $RayCast2D.to_local(to)
	$RayCast2D.force_raycast_update()
	var result = $RayCast2D.get_collider()
	return result

func _on_interactarea_body_entered(_body):
	#print(_body, " entered")
	if _body.is_in_group("interactpoints") and raycast(_body.global_position) == _body:
		overlappingPoints.append(_body)
		#using node path to make sure each interact point has a unique key
		pointsData[str(_body.get_path()).replace("/", "")] = _body.get_interact_data()
	updateInteraction()

func _on_interactarea_body_exited(_body):
	#print(_body, " exited")
	overlappingPoints.erase(_body)
# warning-ignore:return_value_discarded
	pointsData.erase(str(_body.get_path()).replace("/", ""))
	updateInteraction()
