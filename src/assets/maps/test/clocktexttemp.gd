extends Label

func _ready():
	MapManager.connect("interacted_with", self, "interacted_with")

func interacted_with(interactNode, from, interact_data):
	if interactNode != self:
		return
	if from.name == "clockset" and interact_data.has("newText"):
		text = interact_data["newText"]
		return
	UIManager.open_menu("clockset", {"linkedNode": self, "currentTime": int(text)})
