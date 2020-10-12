extends ScrollContainer

export (NodePath) var resDropdown_path
onready var resDropdown = get_node(resDropdown_path)

func _ready():
	$VBoxContainer/Back.connect("pressed", get_node(".."), "_on_Return")
	$VBoxContainer/resDropdown
	addItems()

func _on_Fullscreen_toggle_toggled(button_pressed):
	OS.window_fullscreen = button_pressed

func addItems():
	resDropdown.add_item("1024x768")
	resDropdown.add_item("1366x768")
	
