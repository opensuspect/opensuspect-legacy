extends Button
func _ready():
	GameManager.connect("state_changed", self, "state_changed")

func state_changed(old_state, new_state):
	if new_state == GameManager.State.Normal:
		self.set_position(Vector2(0,10000))

func _on_Button_pressed():
	UIManager.open_menu("chatbox")
