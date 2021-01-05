extends Area2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
export(Resource) var interact_resource
var interacting:bool = false
var interactor:Dictionary
#To do in this file
#Just add a shader to sprite

# Called when the node enters the scene tree for the first time.
func _ready():#Give the ui_resfull control
	interact_resource.init_resource(self)
	pass # Replace with function body.


func reset() -> void: #resets the node
	interacting == false
	interactor.clear()
	
func register(body) -> void:#Register a body
	interactor[body.id] = body
	return 


func _on_Area2D_body_entered(body):#Check wether the body is player or not and record the player
	for bodies in get_overlapping_bodies():
		if bodies.is_in_group("players"):
			if interactor.empty():
				register(bodies)
			else:
				return
				

func _input(event):#Checks that the player presses the key is in interacting dic
	if event.is_action_pressed("interact") and interactor.keys().has(Network.get_my_id()):
		interact(interactor)
	

func _on_Area2D_body_exited(body):#Closes the ui[I will also use ui_res here]
	UIManager.close_ui("container")
	reset()
	
func interact(interactor):#The main func to pass data
	interact_resource.interact(self,interactor)
