extends MarginContainer

onready var grid = $background/conatainergrid

const slot_scene = preload("res://assets/ui/tasks/container/itemslot.tscn")


export(int) var slots 
var ui_data:Dictionary #Contains player which is interacting
#var slots_data:Array

func _ready():#connects with GameManager to record game transition
	if grid.get_child(0) == null:
		rpc("set_slot")#When the first player interacts then called this func to all others so everyone get the same scene set
	GameManager.connect('state_changed', self, '_on_state_changed')

func open() -> void:
	show()

func close() -> void:
	hide()

func _process(_delta):#Called every frame to check interaction status
	if !ui_data.empty():
		pass_data(ui_data)
	else:
		erase_data()

func _on_closebutton_pressed():#Resets the data which is passed
	UIManager.close_ui("conatiner")
	reset()
	close()

remotesync func set_slot():#Place where the scene is built
	for num in range(0, slots):
		var slot = slot_scene.instance()
		slot.set_name(str(num))
		slot.index = num
		grid.add_child(slot)

func pass_data(data:Dictionary):#Pass data to child
	for slot in grid.get_children():
		slot.ui_data = data
		
func erase_data():#Erase data from child
	for slot in grid.get_children():
		slot.ui_data.empty()

func erase_child():#erases all child
	for child in grid.get_children():
		child.queue_free()

func reset():#Clears all the data
	erase_data()
	ui_data.clear()
	
#			
func _on_state_changed(_old_state, new_state) -> void:#resets the task when state changes
	match new_state:
		GameManager.State.Normal:
			set_slot()
			print("STATE NORMAL")
		GameManager.State.Lobby:
			erase_child()
			reset()
			print("STATE LOBBY")
