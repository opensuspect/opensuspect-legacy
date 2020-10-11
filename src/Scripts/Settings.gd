extends ScrollContainer
func _ready():
	$VBoxContainer/Back.connect("pressed", get_node(".."), "_on_Return")

func _on_Fullscreen_toggle_toggled(button_pressed):
	OS.window_fullscreen = button_pressed
