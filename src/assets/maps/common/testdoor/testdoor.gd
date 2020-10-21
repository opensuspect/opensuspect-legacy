extends StaticBody2D

#if true, door will slide to the left
var openLeft: bool = true 
var open: bool = false

func _ready():
	MapManager.connect("interacted_with", self, "interacted_with")
	GameManager.connect("state_changed", self, "state_changed")

func interact():
	if open:
		close()
	else:
		open()

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
	if interactNode == self:
		interact()

func state_changed(old_state, new_state):
	if new_state == GameManager.State.Normal:
		MapManager.interact_with(self)
