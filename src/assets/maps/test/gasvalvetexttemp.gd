extends Label

func _ready():
# warning-ignore:return_value_discarded
	MapManager.connect("interacted_with", self, "interacted_with")

func interacted_with(interactNode, from, interact_data):
	if interactNode != self:
		return
	if PlayerManager.assignedtasks[0] == 0:
		UIManager.open_menu("gasvalve", {"linkedNode": self})
#test if client has correct assigned task
