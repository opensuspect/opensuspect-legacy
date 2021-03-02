extends Area2D

export(Resource) var interact_resource
var interacting:bool = false
var interactor:Dictionary
var player = null
#TODO:Add a shader


func _ready():
	interact_resource.init_resource(self)
	interact_resource.update(self, {},interact_resource.actions.UPDATE)

func reset() -> void: #Resets the node
	interacting = false
	player = null
	interactor.clear()
	
func register(body) -> void:#Register a body
	interactor[body.id] = body.get_path()
	return 

func _input(event):#Checks that the player presses the key is in interacting dic
	if event.is_action_pressed("interact") and interactor.keys().has(Network.get_my_id()) and interacting:
		player.can_pickup = false
		interact(interactor, interact_resource.actions.OPEN)

func _on_Container_body_entered(_body):#Check wether the body is player or not and record the player
	for bodies in get_overlapping_bodies():
		if bodies.is_in_group("players"):
			if can_interact():
				player = bodies
				register(bodies)


func _on_Container_body_exited(body):#Closes the ui
	if body.is_in_group("players"):
		body.can_pickup = true
	interact({},interact_resource.actions.CLOSE)
	reset()
	
func interact(ui_data:Dictionary = {}, value = interact_resource.actions.OPEN):
	interact_resource.interact(self,ui_data, value)

func can_interact() -> bool:
	if not interactor.empty():
		interacting = false
		return false
	else:
		interacting = true
		return true 
