extends Area2D

#export(Resource) var interact_resource
var pressed:bool = false
var interacting:bool = false
var interactor:Dictionary
#TODO:Add a shader


func _ready():
	#interact_resource.init_resource(self)
	pass 

func reset() -> void: #Resets the node
	interacting = false
	pressed = false
	interactor.clear()
	
func register(body) -> void:#Register a body
	interactor[body.id] = body.get_path()
	interactor["bool"] = true
	return 

func _input(event):#Checks that the player presses the key is in interacting dic
	if event.is_action_pressed("interact") and interactor.keys().has(Network.get_my_id()):
		interacting = true
		pressed = true
		UIManager.open_ui("container", interactor)
		#interact(interactor)

func _on_Container_body_entered(_body):#Check wether the body is player or not and record the player
	for bodies in get_overlapping_bodies():
		if bodies.is_in_group("players"):
			if interactor.empty():
				register(bodies)
			else:
				return


func _on_Container_body_exited(_body):#Closes the ui
	UIManager.close_ui("container")
	reset()
	
#func interact(interactor):#The main func to pass data
#	interact_resource.interact(self,interactor)
