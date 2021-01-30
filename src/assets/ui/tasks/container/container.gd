extends MarginContainerBase

onready var grid = $background/conatainergrid

const slot_scene = preload("res://assets/ui/tasks/container/itemslot.tscn")

var pressed:bool= false

export(int) var slots 
#var slots_data:Array

func _ready():
#When the first player interacts then called this func to all others so everyone get the same scene set
	if grid.get_child(0) == null:
		rpc_id(1,"set_slot_server")
#Connects with GameManager to record game transition
	GameManager.connect('state_changed', self, '_on_state_changed')


func _process(_delta):#Called every frame to check interaction status
	if ui_data.has("bool"):
		rpc_id(1, "pass_data_server", ui_data)

func _on_closebutton_pressed():#Resets the data which is passed
	UIManager.close_ui("container")
	rpc_id(1, "reset_server")

puppetsync func set_slot():
	#Place where the scene is built
	for num in range(0, slots):
		var slot = slot_scene.instance()
		slot.set_name(str(num))
		slot.index = num
		slot.get_child(0).frontend = slot
		grid.add_child(slot)

puppetsync func pass_data(data:Dictionary):#Pass data to child
	for slot in grid.get_children():
		slot.ui_data = data
		
func erase_data():#Erase data from child
	for slot in grid.get_children():
		slot.ui_data.clear()

puppetsync func erase_child():#erases all child
	for child in grid.get_children():
		child.queue_free()

puppetsync func reset():#Clears all the data
	erase_data()
	ui_data.clear()
	
#			
func _on_state_changed(_old_state, new_state) -> void:#resets the task when state changes
	match new_state:
		GameManager.State.Normal:
			if grid.get_child(0) == null:
				rpc_id(1,"set_slot_server")
		GameManager.State.Lobby:
			rpc_id(1, "erase_child_server")
			rpc_id(1, "reset_server")
			
remotesync func set_slot_server():
	if not get_tree().is_network_server():
		return
	rpc("set_slot")

remotesync func pass_data_server(data:Dictionary):
	if not get_tree().is_network_server():
		return
	rpc("pass_data", data)
	
remotesync func reset_server():
	if not get_tree().is_network_server():
		return
	rpc("reset")
remotesync func erase_child_server():
	if not get_tree().is_network_server():
		return
	rpc("erase_child")



