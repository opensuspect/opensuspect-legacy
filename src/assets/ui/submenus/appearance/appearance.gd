extends Control

# Node to put settings
export var scroll_cont: NodePath

# Init config
onready var config = ConfigFile.new()

# Wrapper function to save and update setting
func _save_state(key, value):
	config.set_value("appearance", key, value)
	config.save("user://appearance.cfg")


func _ready():
	# Load configuration
	var err = config.load("user://appearance.cfg")
	if err != OK:
		raise()
	
	# Load color
	var color = config.get_value("appearance", "color")
	if color != null:
		$Appearance/VBoxContainer/CenterContainer/ColorSelector.selectedColor = color


	# Init appearance view
	var vbox = $Appearance/VBoxContainer

	# Init back button
	var back_button = Button.new()
	back_button.text = tr("Back")
	back_button.connect("pressed", get_node(".."), "_on_Return")
	vbox.add_child(back_button)


func _on_ColorSelector_color_change(color : Color):
	_save_state("color", color.to_rgba32())
