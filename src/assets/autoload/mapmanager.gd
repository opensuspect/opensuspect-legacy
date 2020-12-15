extends Node

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
	var root = get_tree().get_root()
	var interact_node_path = root.get_path_to(interact_node)
	var from_node_path = root.get_path_to(from)
	if get_tree().is_network_server():
		rpc("receive_map_interaction", interact_node_path, from_node_path, interact_data)
	else:
		rpc_id(1, "receive_map_interaction_server", interact_node_path, from_node_path, interact_data)

puppet func receive_map_interaction(interact_node_path: NodePath, from_node_path: NodePath, interact_data: Dictionary = {}):
	if get_tree().is_network_server():
		return
	var root = get_tree().get_root()
	var interact_node = root.get_node_or_null(interact_node_path)
	var from = root.get_node_or_null(from_node_path)
	if interact_node == null:
		push_error("failed to receive interaction, trying to interact with a null instance")
		return
	if from == null:
		push_error("failed to receive interaction, from is null")
		return
	emit_signal("interacted_with", interact_node, from, interact_data)

# right now any client can rpc this function and execute any map interaction they want, this is extremely easy to exploit
# for now I'm going to disable this function, if you have any ideas on how to make this safer please share!
remote func receive_map_interaction_server(interact_node_path: NodePath, from_node_path: NodePath, interact_data: Dictionary = {}):
	# or true is so that this function will not do anything
	if not get_tree().is_network_server() or true:
		return
	var root = get_tree().get_root()
	var interact_node = root.get_node_or_null(interact_node_path)
	var from = root.get_node_or_null(from_node_path)
	if interact_node == null:
		push_error("failed to receive interaction, trying to interact with a null instance")
		return
	if from == null:
		push_error("failed to receive interaction, from is null")
		return
	# verify interaction here? I'm not sure how you could verify it
	broadcast_map_interaction(interact_node, from, interact_data)
	emit_signal("interacted_with", interact_node, from, interact_data)
