extends Node

onready var main: Node2D

signal interacted_with

func _ready():
	set_network_master(1)

#each interactable node will store info about what should happen when it is
#interacted with, just sending the node lets the receiver handle it completely
#it also prevents this script from limiting the game
#from is where the interaction came from (player, button, etc.)
func interact_with(interact_node: Node, from: Node, interact_data: Dictionary = {}, broadcast: bool = false):
	#put checks and stuff here
	#print("signalling interact with ", interactNode.name)
	if interact_node == null:
		push_error("failed to interact, trying to interact with a null instance")
		return
	if from == null:
		push_error("failed to interact, from is null")
		return
	if broadcast:
		broadcast_map_interaction(interact_node, from, interact_data)
	emit_signal("interacted_with", interact_node, from, interact_data)

func broadcast_map_interaction(interact_node: Node, from: Node, interact_data: Dictionary = {}):
	if interact_node == null:
		push_error("failed to broadcast interaction, trying to interact with a null instance")
		return
	if from == null:
		push_error("failed to broadcast interaction, from is null")
		return
	var interact_node_path = Helpers.get_absolute_path_to(interact_node)
	var from_node_path = Helpers.get_absolute_path_to(from)
	var parsed_data: Dictionary = parse_for_networking(interact_data)
	if get_tree().is_network_server():
		rpc("receive_map_interaction", interact_node_path, from_node_path, parsed_data)
	else:
		rpc_id(1, "receive_map_interaction_server", interact_node_path, from_node_path, parsed_data)

puppet func receive_map_interaction(interact_node_path: NodePath, from_node_path: NodePath, parsed_data: Dictionary = {}):
	if get_tree().is_network_server():
		return
	var interact_node = Helpers.get_node_or_null_from_root(interact_node_path)
	var from = Helpers.get_node_or_null_from_root(from_node_path)
	if interact_node == null:
		push_error("failed to receive interaction, trying to interact with a null instance")
		return
	if from == null:
		push_error("failed to receive interaction, from is null")
		return
	var interact_data: Dictionary = parse_from_networking(parsed_data)
	emit_signal("interacted_with", interact_node, from, interact_data)

# right now any client can rpc this function and execute any map interaction they want, this is extremely easy to exploit
# for now I'm going to disable this function, if you have any ideas on how to make this safer please share!
remote func receive_map_interaction_server(interact_node_path: NodePath, from_node_path: NodePath, parsed_data: Dictionary = {}):
	# or true is so that this function will not do anything
	if not get_tree().is_network_server() or true:
		return
	var interact_node = Helpers.get_node_or_null_from_root(interact_node_path)
	var from = Helpers.get_node_or_null_from_root(from_node_path)
	if interact_node == null:
		push_error("failed to receive interaction, trying to interact with a null instance")
		return
	if from == null:
		push_error("failed to receive interaction, from is null")
		return
	var interact_data: Dictionary = parse_from_networking(parsed_data)
	# verify interaction here? I'm not sure how you could verify it
	broadcast_map_interaction(interact_node, from, parsed_data)
	emit_signal("interacted_with", interact_node, from, interact_data)

# for encoding interact_data in a way that preserves nodes
func parse_for_networking(dict: Dictionary):
	var node_keys: Array = gen_node_keys(dict)
	var parsed_dict: Dictionary = dict
	for key in node_keys:
		parsed_dict[key] = Helpers.get_absolute_path_to(dict[key])
	var return_dict: Dictionary = {}
	return_dict["node_keys"] = node_keys
	return_dict["parsed_dict"] = parsed_dict
	return return_dict

func parse_from_networking(dict: Dictionary):
	var return_dict = dict["parsed_dict"]
	for key in dict["node_keys"]:
		return_dict[key] = Helpers.get_node_or_null_from_root(return_dict[key])
	return return_dict

# warning-ignore:unused_argument
# warning-ignore:unused_argument

func get_current_map() -> Node:
	return get_tree().get_root().get_node("Main/maps").get_child(0)

func gen_node_keys(dict: Dictionary) -> Array:
	var node_keys: Array = []
	for key in dict.keys():
		if dict[key] is Node:
			node_keys.append(key)
	return node_keys
