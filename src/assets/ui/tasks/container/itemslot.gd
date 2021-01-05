extends MarginContainer



var ui_data:Dictionary
var mouse_entered:bool
var index:int



#To do in this file
#set a randomiser to randomise the item spawning
#SYNC THE STATE OF THE TASK


func _ready():
	pass

#func update_state(index_to_change):{#Sends the signal to update}
#	if get_child(0) != null:
#		rpc("remove_child", index_to_change)

func _on_itemslot_mouse_entered():#Gives the hovering effect
	if get_child_count() == 0:
		return
	else:
		get_child(0).animator.play("hover")
		get_child(0).can_pickup_with_mouse = true
		mouse_entered = true


func _on_itemslot_mouse_exited():#give the item idle state
	if get_child_count() == 0:
		return
	else:
		get_child(0).animator.play("idle")
		get_child(0).can_pickup_with_mouse = false
		mouse_entered = false


func _on_itemslot_gui_input(event):#when mouse is clicked on slot
	if event is InputEventMouseButton and event.pressed and event.button_index == BUTTON_LEFT and mouse_entered == true:
		if get_child(0) != null:
			set_in_hand(ui_data, get_child(0))
			#update_state(index)  #{Tried to do: pass a func to update the state in every task}
			

func set_in_hand(ui_data:Dictionary, item):#This the crucial function
	#By only this the  item from the itemslot get transferredd to hand
	for key in ui_data.keys():
		if typeof(key) == TYPE_INT:#Filters the ui_data
			var player = ui_data[key]
			set_path(item)
			player.item_handler._test_pickup(item)
			print(item.get_path())



func set_path(item):#Give the item its location so it cna remove itself and add to other location
	var path = self.get_path()
	print(self.get_path())
	item.destination = path
	item.item_from_container = true

	
#remote func remove_child(index_to_change):  {#Func that update the items}
#	print(index_to_change)
	#if index == index_to_change:
	#	get_child(0).queue_free()
	#else:
	#	return
