extends Area2D

export(NodePath) var interact_path
export(Dictionary) var interact_info = {}
export(bool) var only_main_player = false
export(int, 1, 10000) var players_to_activate = 1
var overlappingBodies: Array = []
var pressed: bool = false

func interact():
	if not get_node(interact_path):
		return
	MapManager.interact_with(get_node(interact_path), self, interact_info)

func update():
	if overlappingBodies.size() < players_to_activate:
		if not pressed:
			return
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
	if body.get
	overlappingBodies.append(body)
	update()

func _on_standbutton_body_exited(body):
	overlappingBodies.erase(body)
	update()
