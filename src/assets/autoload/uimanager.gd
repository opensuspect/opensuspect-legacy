extends Node

var filepath = ("user://settings.cfg")
var configfile
var keybinds = {}

var menus: Dictionary = {
						#HUD
						"interactui": {"scene": preload("res://assets/ui/hud/interactui/interactui.tscn")}, 
						
						#common UI
						"pausemenu": {"scene": preload("res://assets/ui/pausemenu/pausemenu.tscn")}, 
						"chatbox": {"scene": preload("res://assets/ui/lobbyui/chatbox/chatbox.tscn")}, 
						
						#task UI
						"clockset": {"scene": preload("res://assets/ui/tasks/clockset/clockset.tscn")}
						}

var openMenus: Array = []

var justClosed: String = ""

var interactUINode: Node

signal open_menu



func _ready():
	configfile = ConfigFile.new()
	configfile.load(filepath)
	check_keybinds(configfile)
	if configfile.load(filepath) == OK:
		for key in configfile.get_section_keys("Keybinds"):
			var key_value = configfile.get_value("Keybinds", key)
			#print(key, ":" ,OS.get_scancode_string(key_value))
			#keybinds[key] = key_value
			if str(key_value) != "":
				keybinds[key] = key_value
			else:
				keybinds[key] = null
	set_game_binds()
	GameManager.connect("state_changed", self, "state_changed")

#menu data is data to pass to the menu, such as a task identifier
#reInstance is whether or not to recreate the corresponding menu node if it already exists
func open_menu(menuName: String, menuData: Dictionary = {}, reInstance: bool = false):
	#print("signalling to open ", menuName)
	if not menus.keys().has(menuName):
		push_error("open_menu() called with invalid menu name " + menuName)
	emit_signal("open_menu", menuName, menuData, reInstance)

func menu_opened(menuName):
	if openMenus.has(menuName):
		return
	openMenus.append(menuName)

func menu_closed(menuName):
	openMenus.erase(menuName)
	justClosed = menuName

func state_changed(old_state, new_state):
	if new_state == GameManager.State.Normal:
		pass
	if new_state == GameManager.State.Start:
		openMenus = []

func in_menu() -> bool:
	return not openMenus.empty()

func get_interact_ui_node():
	return interactUINode

func _process(_delta):
	#if ui_cancel (most likely esc) and not in menu, open pause menu
	if Input.is_action_just_pressed("ui_cancel") and not in_menu() and justClosed != "pausemenu":
		open_menu("pausemenu")
	justClosed = ""


func set_game_binds():#Set new binds
	for key in keybinds.keys():
		var value = keybinds[key]
		var erase
		#Erases the key binds of previous action
		erase = InputMap.action_erase_events(key)
		
		if value != null:
			var new_key = InputEventKey.new()
			new_key.set_scancode(value)
			InputMap.action_add_event(key, new_key)
		
	#print(keybinds)

func write_config():
	for key in keybinds.keys():
		var key_value = keybinds[key]
		if key_value != null:
			configfile.set_value("Keybinds", key, key_value)
		else:
			configfile.set_value("Keybinds", key, "")
	configfile.save(filepath)

func write_keybinds():
	var file = "user://settings.cfg"
	var configFile = ConfigFile.new()
	configFile.load(file)
	configFile.set_value("Keybinds","ui_up",int(87))
	configFile.set_value("Keybinds","ui_down",int(83))
	configFile.set_value("Keybinds","ui_left",int(65))
	configFile.set_value("Keybinds","ui_right",int(68))
	
	configFile.save(file)

func check_keybinds(configfile):
	if (configfile.has_section_key("Keybinds", "ui_up")):
		return 0
	else:
		write_keybinds()
