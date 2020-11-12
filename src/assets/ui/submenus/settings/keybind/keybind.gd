extends CanvasLayer

onready var buttoncontainer = get_node("Panel/VBoxContainer")
onready var buttonscript = load("res://assets/ui/submenus/settings/keybind/keybutton.gd")

var keybinds
var buttons = {}

func _ready():
	keybinds = UIManager.keybinds.duplicate()
	for key in keybinds.keys():
		var hbox = HBoxContainer.new()
		var label = Label.new()
		var button = Button.new()
		
		hbox.set_h_size_flags(Control.SIZE_EXPAND_FILL)
		label.set_h_size_flags(Control.SIZE_EXPAND_FILL)
		button.set_h_size_flags(Control.SIZE_EXPAND_FILL)
		

		var button_value = keybinds[key]
		if button_value != null:
			button.text = OS.get_scancode_string(button_value)
		else:
			button.text = "Unassigned"
		
		label_text(key, label)
		
		button.set_script(buttonscript)
		button.key = key 
		button.value = button_value
		button.menu = self 
		button.toggle_mode = true
		button.focus_mode = Control.FOCUS_NONE
		
		hbox.add_child(label)
		hbox.add_child(button)
		buttoncontainer.add_child(hbox)
		
		buttons[key] = button
	
	
func change_bind(key, value):
	keybinds[key] = value
	for k in keybinds.keys():
		if k != key and value!= null and keybinds[k] == value:
			keybinds[k] = null
			buttons[k].value = null
			buttons[k].text = "Unassigned"
	


func back():
	get_tree().change_scene("res://assets/ui/mainmenu/mainmenu.tscn")



func save():
	UIManager.keybinds = keybinds.duplicate()
	UIManager.set_game_binds()
	UIManager.write_config()
	get_tree().change_scene("res://assets/ui/mainmenu/mainmenu.tscn")

func label_text(key, label):
	if key == "ui_up":
		label.text = "UP"
	elif key == "ui_down":
		label.text = "DOWN"
	elif key == "ui_left":
		label.text = "Left"
	elif key == "ui_right":
		label.text = "Right"
	else:
		label.text = key
		
