extends Label

export(Resource) var interact_resource

func _ready():
# warning-ignore:return_value_discarded
	MapManager.connect("interacted_with", self, "interacted_with")

func interacted_with(interactNode, from, interact_data):
	if interactNode != self:
		return
	if interact_data.has("newText"):
		text = interact_data["newText"]
		return
	if PlayerManager.assignedtasks[0] == 0:
		interact_resource.interact(self, {"linkedNode": self, "currentTime": int(text)})
#test if client has correct assigned task
