extends StaticBody2D

export(Resource) var interact
export(String) var display_text

var interact_data: Dictionary = {} setget , get_interact_data

func _ready():
	interact.init_resource(self)
#	print(interact.get_interact_data())

func get_interact_data():
	#var interact_resource: Interact = interact
	interact_data = interact.get_interact_data()
	interact_data["display_text"] = display_text
	return interact_data

func interact():
	#print(interact_data)
	interact.interact(self)
