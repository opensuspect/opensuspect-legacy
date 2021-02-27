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
