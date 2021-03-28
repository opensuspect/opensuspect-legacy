extends MarginContainerBase

onready var grid = $background/conatainergrid

const slot_scene = preload("res://assets/ui/tasks/container/itemslot.tscn")

var available_items:Dictionary = {
							"large-liquid-bottle":{"scene":preload("res://assets/items/large-liquid-bottle.tscn"),"position":Vector2(40,56),"shift":8,"scale":Vector2(1.5,1.5)},
							"powder-bottle":{"scene":preload("res://assets/items/powder-bottle.tscn"),"position":Vector2(40,80),"shift":8,"scale":Vector2(2,2)},
							"small-liquid-bottle":{"scene":preload("res://assets/items/small-liquid-bottle.tscn"),"position":Vector2(40,64),"shift":8,"scale":Vector2(2,2)}
}
var current_item_instanced:Array = []
var slots_in_grid:Dictionary={}
 
export(int) var slots 

func _ready():
#When the first player interacts then called this func to all others so everyone get the same scene set
#Connects with GameManager to record game transition
# warning-ignore:return_value_discarded
#	GameManager.connect('state_changed', self, '_on_state_changed')
	pass

func _on_closebutton_pressed():#Resets the data which is passed
	for key in ui_data.keys():
		if typeof(key) == TYPE_INT:
			var player = ui_data[key]
			get_tree().get_root().get_node(player).can_pickup = true
	interact({},get_res().actions.CLOSE)

func _on_set_scene() -> void:
	print("called")
	#Place where the scene is built
	for num in range(0, slots):
		var slot = slot_scene.instance()
		slot.index = num
		slot.container = self
		if can_set_up_items(slot):
			grid.add_child(slot)
#		var item_to_instance = place_item(slot)
#		if item_to_instance == null:
#			break
#		var number_of_item = set_amount(slot)
#		slots_in_grid[slot.index] = {"slot":slot,"item_instanced":item_to_instance,"number_of_item":number_of_item}
	get_res().slots_info = slots_in_grid

func _on_erase_children() -> void:#erases all child
	for child in grid.get_children():
		child.queue_free()

#func _on_state_changed(_old_state, new_state) -> void:#resets the task when state changes
#	match new_state:
#		GameManager.State.Normal:
#			if grid.get_child(0) == null:
#				rpc_id(1,"set_slot_server")
#		GameManager.State.Lobby:
#			rpc_id(1, "erase_children_server")
#			rpc_id(1, "reset_server")
func get_res() -> Resource:
	var res = TaskManager.get_task_resource(ui_data[TaskManager.TASK_ID_KEY])
	return res


func interact(data:Dictionary = {}, value = get_res().actions.OPEN):
	get_res().interact(self,data, value)

func update():
# warning-ignore:return_value_discarded
	get_res().connect("set_scene", self, "_on_set_scene")
	get_res().connect("erase_children", self, "_on_erase_children")

#func randomizer(item,number_of_item):
#	var item_as_child 
#	for items in available_items.keys():
#		if item == items:
#			for item in range(0, number_of_item):
#				item_as_child = available_items[item].scene.instance()
#			return item_as_child

#func set_position_and_add_child(slot, item):
#	item.position += Vector2(64,64)
#	slot.add_child(item)


func set_amount(slot):
	var number_of_item = Helpers.pick_random(range(0,11))
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
		slots_in_grid[slot.index] = {"slot":slot,"item_instanced":item_to_instanced,"number_of_item":number_of_item}
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
		#var item_shift = available_items[item_name].shift
		#print(item.position)
		#var position = item.position
		#position.x += item_shift
		#position.y -= item_shift
		#print(position)
		#item.position = position 
	
	
