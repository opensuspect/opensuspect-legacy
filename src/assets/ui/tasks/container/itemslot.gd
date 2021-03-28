extends MarginContainerBase

onready var amount = $Control/Label
onready var itemslot = self

var mouse_entered:bool
var index:int
var container

func _ready():
	pass
	

func _on_Control_gui_input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == BUTTON_LEFT and mouse_entered == true:
		if itemslot.get_child(0) != null:
			container.get_res().generate_interact_data(index)


func _on_itemslot_mouse_entered():
	if itemslot.get_child_count() == 0:
		return
	else:
		itemslot.get_child(get_child_count() - 1).animator.play("hover")
		itemslot.get_child(get_child_count() - 1).can_pickup_with_mouse = true
		mouse_entered = true


func _on_itemslot_mouse_exited():
	if itemslot.get_child_count() == 0:
		return
	else:
		itemslot.get_child(get_child_count() - 1).animator.play("idle")
		itemslot.get_child(get_child_count() - 1).can_pickup_with_mouse = false
		mouse_entered = false
