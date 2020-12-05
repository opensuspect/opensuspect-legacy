extends Button

func _ready():
# warning-ignore:return_value_discarded
	GameManager.connect("state_changed", self, "state_changed")

# warning-ignore:unused_argument
func state_changed(old_state, new_state):
	match new_state:
		GameManager.State.Normal:
			hide()
		GameManager.State.Lobby:
			show()

func _on_Button_pressed():
	UIManager.open_ui("chatbox")
