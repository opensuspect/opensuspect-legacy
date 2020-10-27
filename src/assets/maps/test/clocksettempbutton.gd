extends Button

export(NodePath) var interact_path

func _on_clocksettempbutton_pressed():
	if not get_node(interact_path):
		return
	UIManager.open_menu("clockset", {"linkedNode": get_node(interact_path), "currentTime": int(get_node(interact_path).text)})
