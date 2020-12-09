extends StaticBody2D

export(Resource) var interact_resource
export(String) var display_text

var interact_data: Dictionary = {} setget , get_interact_data

func _ready():
	interact_resource.init_resource(self)

func get_interact_data():
	#var interact_resource: Interact = interact
	interact_data = interact_resource.get_interact_data(self)
	interact_data["display_text"] = display_text
	#interact_data["interact_resource"] = interact_resource
	interact_data["interact_node"] = self
	return interact_data

func interact():
	#print(interact_data)
	interact_resource.interact(self)
