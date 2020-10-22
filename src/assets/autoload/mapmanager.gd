extends Node



signal interacted_with

func _ready():
	GameManager.connect("state_changed", self, "state_changed")

#each interactable node will store info about what should happen when it is
#interacted with, just sending the node lets the receiver handle it completely
#it also prevents this script from limiting the game
#from is where the interaction came from (player, button, etc.)
func interact_with(interactNode: Node, from: Node = null):
	#put checks and stuff here
	#print("signalling interact with ", interactNode.name)
	emit_signal("interacted_with", interactNode, from)
