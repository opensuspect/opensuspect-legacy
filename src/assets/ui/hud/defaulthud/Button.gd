extends Button

func _ready():
	GameManager.connect("state_changed", self, "state_changed")

func state_changed(old_state, new_state):
	match new_state:
		GameManager.State.Normal:
			hide()
		GameManager.State.Lobby:
			show()

func _on_Button_pressed():
	UIManager.open_menu("chatbox")
