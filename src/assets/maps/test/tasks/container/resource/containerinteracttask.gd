tool
extends InteractTask

enum actions {OPEN, INSTANCE, UPDATE, CLOSE}

signal set_scene
signal erase_children

var slots_info:Dictionary = {}
var available_items:Dictionary = TaskManager.available_items

var current_item_instanced:Array = []
var items_to_hold:Array = ["battery","wrench"]

var player_data = null
var interact_data:Dictionary = {}

func _init():
	add_networked_func("_server_set_scene", MultiplayerAPI.RPC_MODE_MASTER)
	add_networked_func("_client_set_scene", MultiplayerAPI.RPC_MODE_PUPPET)
	add_networked_func("_server_erase_children", MultiplayerAPI.RPC_MODE_MASTER)
	add_networked_func("_client_erase_children", MultiplayerAPI.RPC_MODE_PUPPET)
	
	GameManager.connect("state_changed",self,"_on_state_changed")
	
func set_action(value):
	match value:
		actions.OPEN:
			ui_res.action = actions.OPEN
		actions.INSTANCE:
			ui_res.action = actions.INSTANCE
		actions.UPDATE:
			ui_res.action = actions.UPDATE
		actions.CLOSE:
			ui_res.action = actions.CLOSE

func interact(_from: Node = null, _interact_data: Dictionary = {}, value = actions.OPEN):
	if attached_to == null and _from != null:
		attached_to = _from
	if attached_to == null:
		push_error("InteractTask resource trying to be used with no defined node")
	if not is_player_assigned(Network.get_my_id()):
		return
	if is_task_completed(Network.get_my_id()):
		return
	player_data = _interact_data
	var merged_dic = Helpers.merge_dicts(_interact_data, get_task_data())
	set_action(value)
	ui_res.interact(_from, merged_dic)
	
func update(_from, _data, value):
	set_action(value)
	ui_res.interact(_from,task_data)
	sync_task()


func _sync_task():
	task_rpc("_server_set_scene")

func _server_set_scene():
	emit_signal("set_scene")
	task_rpc("_client_set_scene")
	
func _server_erase_children():
	emit_signal("erase_children")
	task_rpc("_client_erase_children")

func _client_set_scene():
	emit_signal("set_scene")

func _client_erase_children():
	emit_signal("erase_children")

func _on_state_changed(_old_state, new_state) -> void:#resets the task when state changes
	match new_state:
		GameManager.State.Lobby:
			task_rpc("_server_erase_children")
			

func set_amount(slot):
	var number_of_item = Helpers.pick_random(range(0,5))
	return number_of_item

func random_item(slot):
	var item_to_instance = Helpers.pick_random(available_items.keys())
	if current_item_instanced.has(item_to_instance):
		return null
	else:
		current_item_instanced.append(item_to_instance)
		return item_to_instance

func can_set_up_items(slot) -> bool:
	var item_as_child
	var item_to_instanced = random_item(slot)
	if item_to_instanced == null:
		return false
	print(item_to_instanced)
	var number_of_item = set_amount(slot)
	
	if not available_items.keys().has(item_to_instanced):
		return false
	
	for item_count in range(0,number_of_item):
		item_as_child = available_items[item_to_instanced].scene.instance()
		slot.add_child(item_as_child)
		slot.move_child(item_as_child,0)
		set_item_position(item_to_instanced,item_as_child,item_count,number_of_item)
		slots_info[slot.index] = {"slot":slot,"item_instanced":item_to_instanced,"number_of_item":number_of_item}
	return true
	#set_position_and_add_child(slot, randomizer(item_to_instanced,number_of_item))
	
func set_item_position(item_name,item,item_count,number_of_item):
	var item_scale = available_items[item_name].scale
	item.set_scale(item_scale)
	item.position += available_items[item_name].position
	if not item_count != 0:
		return
	var item_shift = available_items[item_name].shift
	var position = item.position
	position.x += item_count * item_shift
	position.y -= item_count * item_shift
	item.position = position

func generate_interact_data(slot_index):
	for index in slots_info.keys():
		if index == slot_index:
			interact_data = slots_info[index].duplicate()
			send_interact_data(filter_data())
			update_scene()

func send_interact_data(interact_data:Dictionary={}):
	var merged_dic = Helpers.merge_dicts(interact_data, player_data)
	if map_outputs_on:
		for resource in map_outputs:
			resource.interact(attached_to, merged_dic)

func filter_data():
	var number = interact_data["number_of_item"]
	if number == 0:
		return 

	var key_to_remove=["number_of_item","slot"]
	var filtered_data:Dictionary = interact_data.duplicate()
	
	for key in key_to_remove:
		filtered_data.erase(key_to_remove)
		
	return filtered_data
	
func update_scene():
	var updated_data = interact_data.duplicate()
	var number = int(updated_data["number_of_item"])
	updated_data["number_of_item"] = str(number - 1)
	interact_data = updated_data
	update_slot()
	
func update_slot():
	var slot = interact_data["slot"]
	slot.get_child(0).queue_free()
		
