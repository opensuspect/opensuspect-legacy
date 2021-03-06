extends MarginContainerBase

onready var grid = $background/conatainergrid

const slot_scene = preload("res://assets/ui/tasks/container/itemslot.tscn")

var available_items:Dictionary = {
							"battery":{"scene":preload("res://assets/items/battery.tscn")},
							"wrench":{"scene":preload("res://assets/items/wrench.tscn")},
							"large-liquid-bottle":{"scene":preload("res://assets/items/large-liquid-bottle.tscn")},
							"powder-bottle":{"scene":preload("res://assets/items/powder-bottle.tscn")},
							"small-liquid-bottle":{"scene":preload("res://assets/items/small-liquid-bottle.tscn")}
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
	#Place where the scene is built
	for num in range(0, slots):
		var slot = slot_scene.instance()
		slot.index = num
		slot.container = self
		grid.add_child(slot)
		var item_to_instance = place_item(slot)
		if item_to_instance == null:
			break
		var number_of_item = set_amount(slot)
		slots_in_grid[slot.index] = {"slot":slot,"item_instanced":item_to_instance,"number_of_item":number_of_item}
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

func randomizer(item):
	for items in available_items.keys():
		if item == items:
			var item_as_child = available_items[item].scene.instance()
			return item_as_child

func set_position_and_add_child(slot, item):
	item.position += Vector2(64,64)
	slot.add_child(item)


func set_amount(slot):
	var number_of_item = Helpers.pick_random(range(0,11))
	slot.amount.text = str(number_of_item)
	return number_of_item

func place_item(slot):
	var item_to_instance = Helpers.pick_random(available_items.keys())
	if current_item_instanced.has(item_to_instance):
		return null
	else:
		current_item_instanced.append(item_to_instance)
		set_position_and_add_child(slot, randomizer(item_to_instance))
		return item_to_instance
