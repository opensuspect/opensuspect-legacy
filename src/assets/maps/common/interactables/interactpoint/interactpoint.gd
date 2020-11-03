extends StaticBody2D

enum type {node, ui}
export(String) var display_text
export(type) var node_or_ui
export(NodePath) var node_path
export(String) var ui_name
export(Dictionary) var interact_info = {"linkedNode": get_node(node_path)}

var interact_data: Dictionary = {"display_text": display_text}

func _ready():
	match node_or_ui:
		type.node:
			interact_data["interact"] = get_node(node_path)
		type.ui:
			interact_data["interact"] = ui_name

func get_interact_data():
	return interact_data

func interact():
	match node_or_ui:
		type.node:
			if not get_node(node_path):
				return
			MapManager.interact_with(get_node(node_path), self, interact_info)
		type.ui:
			UIManager.open_menu(ui_name, interact_info)

