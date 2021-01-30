extends Node

var frontend = null

func _ready():
	frontend.connect("input_received", self, "on_input_received")

func set_in_hand(ui_data_pass, index:int):#This the crucial function
	if not frontend.index == index:
		return
	else:
		var item = frontend.get_child(1)
	#By only this the  item from the itemslot get transferredd to hand
		for key in ui_data_pass.keys():
			if typeof(key) == TYPE_INT:#Filters the ui_data
				var player = ui_data_pass[key]
				get_tree().get_root().get_node(player).item_handler._test_pickup(item)

puppetsync func set_path():#Give the item its location so it cna remove itself and add to other location
	var item = frontend.get_child(1)
	var self_path = get_parent().get_path()
	item.item_location = self_path
	item.item_from_container = true

func on_input_received(ui_data:Dictionary, index:int):
	rpc_id(1, "set_server")
	set_in_hand(ui_data,index)

remotesync func set_server():
	if not get_tree().is_network_server():
		return
	var id: int = get_tree().get_rpc_sender_id()
	if not Network.peers.has(id):
		return
	rpc("set_path")
