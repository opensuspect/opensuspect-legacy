extends Node2D

onready var map_items: Node2D
# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var available_items:Dictionary = {
							"battery":{"scene":preload("res://assets/items/battery.tscn")},
							"wrench":{"scene":preload("res://assets/items/wrench.tscn")}
}
var total_items:Array=[]
var data = null
# Called when the node enters the scene tree for the first time.
func _ready():
	MapManager.connect("interacted_with", self, "on_interacted_with")
	yield(get_tree(), "idle_frame")
	update_total_items()
	map_items = MapManager.get_current_map().items

func on_interacted_with(interactNode, from, interact_data):
	if interactNode != self:
		return
	print(interact_data)
	data = interact_data
	print(data)
	add_item(interact_data["item_instanced"])


func add_item(item_instanced):
	for items in available_items.keys():
		if item_instanced == items:
			var item_as_child = available_items[item_instanced].scene.instance()
			
			map_items.add_child(item_as_child)
			get_tree().get_root().get_node(get_player()).item_handler._test_pickup(item_as_child)
			

func update_total_items():
	for items in available_items.keys():
		total_items.append(items)

func do_match(value):
	for items in total_items:
		match items:
			value:
				add_item(items)
				return true

func get_player():
	for key in data.keys():
			if typeof(key) == TYPE_INT:#Filters the ui_data
				var player = data[key]
				return player
