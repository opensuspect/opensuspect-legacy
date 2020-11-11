extends Node



signal interacted_with

func _ready():
# warning-ignore:return_value_discarded
	GameManager.connect("state_changed", self, "state_changed")

#each interactable node will store info about what should happen when it is
#interacted with, just sending the node lets the receiver handle it completely
#it also prevents this script from limiting the game
#from is where the interaction came from (player, button, etc.)
func interact_with(interactNode: Node, from: Node, interact_data: Dictionary = {}):
	#put checks and stuff here
	#print("signalling interact with ", interactNode.name)
	if interactNode == null or from == null:
		print("failed to interact, trying to interact with a null instance")
		return
	emit_signal("interacted_with", interactNode, from, interact_data)

# warning-ignore:unused_argument
# warning-ignore:unused_argument
func state_changed(old_state, new_state):
	pass
