extends StaticBody2D

#if true, door will slide to the left
var openLeft: bool = true 
var open: bool = false

func _ready():
	MapManager.connect("interacted_with", self, "interacted_with")
	GameManager.connect("state_changed", self, "state_changed")

func toggle(newState: bool = not open):
	if newState:
		open()
	else:
		close()

func open():
	if openLeft:
		position.x -= 40
	else:
		position.x += 40
	open = true

func close():
	if openLeft:
		position.x += 40
	else:
		position.x -= 40
	open = false

func interacted_with(interactNode: Node, from: Node = null):
	if interactNode != self:
		return
	if not from.has_method("get_state"):
		return
	toggle(from.get_state())

func state_changed(old_state, new_state):
	pass
	#if new_state == GameManager.State.Normal:
	#	MapManager.interact_with(self)
