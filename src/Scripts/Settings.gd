extends ScrollContainer

var music = 10
var sound = 10

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
	
	
func _on_Music_value_changed(value):
	music = value
	emit_signal("button_pressed", "Music")


func _on_Sound_value_changed(value):
	sound = value
	emit_signal("button_pressed", "Sound")


func _on_resDropdown_item_selected(id):
	pass # Replace with function body.
