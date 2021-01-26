extends Node

var filepath = ("user://settings.cfg")
var configfile
var keybinds = {}

var ui_list: Dictionary = {
						#HUD
						"interactui": {"scene": preload("res://assets/ui/hud/interactui/interactui.tscn")},
						"killui": {"scene": preload("res://assets/ui/hud/infiltrator_hud/infiltrator_hud.tscn")},
						"rolescreen": {"scene": preload("res://assets/ui/hud/defaulthud/rolescreen/rolescreen.tscn")},
						
						#common UI
						"pausemenu": {"scene": preload("res://assets/ui/pausemenu/pausemenu.tscn")}, 
						"chatbox": {"scene": preload("res://assets/ui/lobbyui/chatbox/chatbox.tscn")},
						"keybind": {"scene": preload("res://assets/ui/submenus/settings/keybind/keybind.tscn")},
						"appearance_editor": {"scene": preload("res://assets/ui/submenus/appearance_editor/appearance_editor.tscn")},
						
						#task UI
						"clockset": {"scene": preload("res://assets/ui/tasks/clockset/clockset.tscn")}
						}

var current_ui: Control

var open_uis: Array = []

var just_closed: String = ""

var interact_ui_node: Node

var ui_controller_node: Node

signal open_ui(ui_name, ui_data, reinstance)
signal close_ui(ui_name, free)
signal instance_ui(ui_name, ui_data)
signal update_ui(ui_name, ui_data)
signal free_ui(ui_name)
signal close_all_ui()

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
# warning-ignore:return_value_discarded
	GameManager.connect("state_changed", self, "state_changed")

#ui data is data to pass to the ui, such as a task identifier
#reinstance is whether or not to recreate the corresponding ui node if it already exists
func open_ui(ui_name: String, ui_data: Dictionary = {}, reinstance: bool = false):
	#print("signalling to open ", menuName)
	if not ui_list.keys().has(ui_name):
		push_error("open_ui() called with invalid ui name " + ui_name)
	emit_signal("open_ui", ui_name, ui_data, reinstance)

func close_ui(ui_name: String, free: bool = false):
	if not ui_list.keys().has(ui_name):
		push_error("close_ui() called with invalid ui name " + ui_name)
	emit_signal("close_ui", ui_name, free)

func instance_ui(ui_name: String, ui_data: Dictionary = {}):
	print("instance ui ", ui_name)
	if not ui_list.keys().has(ui_name):
		push_error("instance_ui() called with invalid ui name " + ui_name)
	emit_signal("instance_ui", ui_name, ui_data)

func update_ui(ui_name: String, ui_data: Dictionary = {}):
	if not ui_list.keys().has(ui_name):
		push_error("update_ui() called with invalid ui name " + ui_name)
	emit_signal("update_ui", ui_name, ui_data)

func free_ui(ui_name: String):
	if not ui_list.keys().has(ui_name):
		push_error("free_ui() called with invalid ui name " + ui_name)
	emit_signal("free_ui", ui_name)

func close_all_ui(free: bool = false):
	emit_signal("close_all_ui", free)

func get_ui(ui_name: String):
	if not ui_list.keys().has(ui_name):
		push_error("get_ui() called with invalid ui name " + ui_name)
	if ui_controller_node == null:
		push_error("ui_controller_node is null (not set) in UIManager, should be set when the ui controller is created")
		return null
	return ui_controller_node.get_ui(ui_name)

func ui_opened(menuName):
	if open_uis.has(menuName):
		return
	open_uis.append(menuName)
	current_ui = get_ui(menuName)

func ui_closed(menuName):
	open_uis.erase(menuName)
	just_closed = menuName
	if not open_uis.empty():
		current_ui = get_ui(open_uis[-1])

# warning-ignore:unused_argument
func state_changed(old_state, new_state):
	if new_state == GameManager.State.Normal:
		pass
	if new_state == GameManager.State.Start:
		open_uis = []

func in_ui() -> bool:
	return not open_uis.empty()

func get_interact_ui_node():
	return interact_ui_node

func _process(_delta):
	just_closed = ""

func _input(event: InputEvent) -> void:
	#if ui_cancel (most likely esc) and not in menu, open pause menu
	if event.is_action_pressed("ui_cancel") and not in_ui() and just_closed != "pausemenu":
		open_ui("pausemenu")
		ui_opened("pausemenu")

func set_game_binds():#Set new binds
	for key in keybinds.keys():
		var value = keybinds[key]
# warning-ignore:unused_variable
		var erase
		#Erases the key binds of previous action
# warning-ignore:void_assignment
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

# warning-ignore:shadowed_variable
func check_keybinds(configfile):
	if (configfile.has_section_key("Keybinds", "ui_up")):
		return 0
	else:
		write_keybinds()
