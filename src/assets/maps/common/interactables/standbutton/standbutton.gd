extends Area2D

enum type {node, ui}
export(type) var node_or_ui
export(NodePath) var node_path
export(String) var ui_name
export(Dictionary) var interact_info
export(bool) var only_main_player = false
export(int, 1, 10000) var players_to_activate = 1
export(bool) var interact_on_exit = true
var overlappingBodies: Array = []
var pressed: bool = false

func _enter_tree():
	if node_or_ui == type.node:
		interact_info["linkedNode"] = get_node(node_path)

func interact():
	match node_or_ui:
		type.node:
			if not get_node(node_path):
				return
			MapManager.interact_with(get_node(node_path), self, interact_info)
		type.ui:
			UIManager.open_menu(ui_name, interact_info)

func update():
	if overlappingBodies.size() < players_to_activate:
		if not pressed:
			return
		pressed = false
		if interact_on_exit:
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
	if not body.is_in_group("players"):
		return
	if only_main_player:
		if int(body.id) != Network.get_my_id():
			return
	overlappingBodies.append(body)
	update()

func _on_standbutton_body_exited(body):
	overlappingBodies.erase(body)
	update()
