extends StaticBody2D

enum type {node, ui}
export(Resource) var test_resource
export(Array, Resource) var test_array# = [load("res://assets/common/resources/interact/taskinteract/taskinteract.tres")]
export(String) var display_text
export(type) var node_or_ui
export(NodePath) var node_path
export(String) var ui_name
export(Dictionary) var interact_info

var interact_data: Dictionary = {}

func _enter_tree():
	if node_or_ui == type.node:
		interact_info["linkedNode"] = get_node(node_path)

func _ready():
	
	interact_data["display_text"] = display_text
	match node_or_ui:
		type.node:
			interact_data["interact"] = get_node(node_path)
		type.ui:
			interact_data["interact"] = ui_name

func get_interact_data():
	return interact_data

func interact():
	print(test_resource.abc)
	print(test_resource.interact_type.abc)
	match node_or_ui:
		type.node:
			if not get_node(node_path):
				return
			MapManager.interact_with(get_node(node_path), self, interact_info)
		type.ui:
			UIManager.open_menu(ui_name, interact_info)

