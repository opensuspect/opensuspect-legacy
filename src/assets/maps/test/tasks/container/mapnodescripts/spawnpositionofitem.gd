extends Node2D

onready var map_items: Node2D

var available_items:Dictionary = TaskManager.available_items
var total_items:Array=[]
var data = null

func _ready():
	MapManager.connect("interacted_with", self, "on_interacted_with")
	yield(get_tree(), "idle_frame")
	update_total_items()
	map_items = MapManager.get_current_map().items

func on_interacted_with(interactNode, from, interact_data):
	if interactNode != self:
		return
	data = interact_data.duplicate()
	print(data)
	add_item(interact_data["item_instanced"],interact_data["number_of_item"])


func add_item(item_instanced, number):
	for items in available_items.keys():
		if item_instanced == items and int(number) != 0:
			var item_as_child = available_items[item_instanced].scene.instance()
			update_data()
			map_items.add_child(item_as_child)
			get_tree().get_root().get_node(get_player()).item_handler._test_pickup(item_as_child)
			

func update_total_items():
	for items in available_items.keys():
		total_items.append(items)

func get_player():
	for key in data.keys():
			if typeof(key) == TYPE_INT:#Filters the ui_data
				var player = data[key]
				return player
				
func update_data():
	var dic_to_change = data.duplicate()
	var number = int(dic_to_change["number_of_item"])
	dic_to_change["number_of_item"] = str(number - 1)
	data = dic_to_change
	#print(data)
