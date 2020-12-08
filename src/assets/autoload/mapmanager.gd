extends Node

onready var main: Node2D

signal interacted_with

var _current_map: Node setget set_current_map, get_current_map

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
	match new_state:
		GameManager.State.Normal:
			var map: Node = get_tree().get_root().get_node("Main/maps").get_child(0)
			set_current_map(map)

func get_current_map() -> Node:
	return _current_map

func set_current_map(map: Node) -> void:
	_current_map = map
