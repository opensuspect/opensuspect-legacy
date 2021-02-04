extends Area2D

#export(Resource) var interact_resource
var interacting:bool = false
var interactor:Dictionary
var player
#TODO:Add a shader


func _ready():
	#interact_resource.init_resource(self)
	pass 

func reset() -> void: #Resets the node
	interacting = false
	interactor.clear()
	
func register(body) -> void:#Register a body
	interactor[body.id] = body.get_path()
	interactor["bool"] = true
	return 

func _input(event):#Checks that the player presses the key is in interacting dic
	if event.is_action_pressed("interact") and interactor.keys().has(Network.get_my_id()) and interacting:
		print("true _input")
		UIManager.open_ui("container", interactor)
		player.can_pickup = false
		#interact(interactor)

func _on_Container_body_entered(_body):#Check wether the body is player or not and record the player
	for bodies in get_overlapping_bodies():
		if bodies.is_in_group("players"):
			if can_interact():
				player = bodies
				register(bodies)


func _on_Container_body_exited(body):#Closes the ui
	if body.is_in_group("players"):
		body.can_pickup = true
	UIManager.close_ui("container")
	reset()
	
#func interact(interactor):#The main func to pass data
#	interact_resource.interact(self,interactor)

func can_interact() -> bool:
	if not interactor.empty():
		interacting = false
		return false
	else:
		interacting = true
		return true 
	#if body.item_handler.has_item() and body.item_handler._target_item != null:
	#	body.item_handler.drop_item_external()
	#	body.item_handler._target_item.can_pickup_with_mouse = false
	#	interacting = true
	#	return true
	#if body.item_handler.has_item() and body.item_handler._target_item == null and body.item_handler.pickup_enabled == false:
	#	interacting = false
	#	return false
	
	#################################
	#if interactor.empty() and body.item_handler._target_item != null:
	#	interacting =true
	#	body.item_handler._target_item.can_pickup_with_mouse = false
	#	return true
	#elif interactor.empty() and body.item_handler._target_item == null:
	#	interacting = true
#		return true

	#if interactor.empty() and body.item_handler._target_item == null  and body.item_handler.pickup_enabled == false and body.item_handler.has_item() or body.item_handler.has_item() == false:
	#	interacting = true
	#	return true
	#elif interactor.empty() and body.item_handler._target_item != null  and body.item_handler.pickup_enabled == false and body.item_handler.has_item() or body.item_handler.has_item() == false:
	#	interacting = false
	#	return false
	#else:
	#	interacting = false
	#	return false
