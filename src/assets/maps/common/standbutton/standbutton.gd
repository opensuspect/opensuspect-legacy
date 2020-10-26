extends Area2D

export(NodePath) var interact_path
var overlappingBodies: Array = []
var pressed: bool = false

func interact():
	if not get_node(interact_path):
		return
	MapManager.interact_with(get_node(interact_path), self)

func update():
	if overlappingBodies.size() < 1:
		pressed = false
		interact()
	else:
		if pressed:
			return
		pressed = true
		interact()

func get_state() -> bool:
	return pressed

func _on_standbutton_body_entered(body):
	if overlappingBodies.has(body):
		return
	overlappingBodies.append(body)
	update()

func _on_standbutton_body_exited(body):
	overlappingBodies.erase(body)
	update()
