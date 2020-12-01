extends CanvasLayer

var ui_list: Dictionary = UIManager.ui_list

var instanced_uis: Dictionary = {}

onready var config = ConfigFile.new()

func _ready():
	set_network_master(1)
	UIManager.ui_controller_node = self
# warning-ignore:return_value_discarded
	UIManager.connect("open_ui", self, "open_ui")
# warning-ignore:return_value_discarded
	UIManager.connect("close_ui", self, "close_ui")
# warning-ignore:return_value_discarded
	UIManager.connect("instance_ui", self, "instance_ui")
# warning-ignore:return_value_discarded
	UIManager.connect("show_ui", self, "show_ui")
# warning-ignore:return_value_discarded
	UIManager.connect("hide_ui", self, "hide_ui")
	var err = config.load("user://settings.cfg")
	if err == OK:
		$ColorblindRect.material.set_shader_param(
			"mode", config.get_value("general", "colorblind_mode")
		)

	#TODO: better system for auto spawning UIs
	instance_ui("chatbox")
	instance_ui("interactui")

#menu data is data to pass to the menu, such as a task identifier
#reInstance is whether or not to recreate the corresponding menu node if it already exists
func open_ui(ui_name: String, ui_data: Dictionary = {}, reinstance: bool = false):
	update_instanced_uis()
	if not ui_list.keys().has(ui_name):
		return
	if reinstance or not instanced_uis.keys().has(ui_name):
		instance_ui(ui_name, ui_data)
	if ui_data != {} and instanced_uis[ui_name].get("ui_data") != null:
		instanced_uis[ui_name].ui_data = ui_data
	var current_ui = get_ui(ui_name)
	#call open on a lower class, handles ui system integration
	if current_ui.has_method("base_open"):
		current_ui.base_open()
	#call open on the inherited class, most likely the script attached to a given task or menu
	if current_ui.has_method("open"):
		current_ui.open()

func close_ui(ui_name: String, free: bool = false):
	update_instanced_uis()
	if not instanced_uis.has(ui_name):
		return
	var current_ui = get_ui(ui_name)
	#call close on a lower class, handles ui system integration
	if current_ui.has_method("base_close"):
		current_ui.base_close()
	#call close on the inherited class, most likely the script attached to a given task or menu
	if current_ui.has_method("close"):
		current_ui.close()
	if free:
		current_ui.queue_free()

func instance_ui(ui_name: String, ui_data: Dictionary = {}):
	update_instanced_uis()
	if not ui_list.keys().has(ui_name):
		return
	var new_ui = ui_list[ui_name].scene.instance()
	if ui_data != {} and new_ui.get("ui_data") != null:
		new_ui.ui_data = ui_data
	instanced_uis[ui_name] = new_ui
	add_child(new_ui)

func show_ui(ui_name: String, ui_data: Dictionary = {}, reinstance: bool = false):
	update_instanced_uis()
	pass

func hide_ui(ui_name: String, free: bool = false):
	update_instanced_uis()
	var current_ui = get_ui(ui_name)
	if free:
		current_ui.queue_free()

func get_ui(ui_name: String):
	update_instanced_uis()
	return instanced_uis[ui_name]

func update_instanced_uis() -> void:
	var child_nodes: Array = get_child_node_names()
	var temp_instanced_uis = instanced_uis.duplicate()
	for i in temp_instanced_uis.keys():
		if not child_nodes.has(i):
			temp_instanced_uis.erase(i)
			child_nodes.erase(i)
	for i in child_nodes:
		push_error("UI element instanced incorrectly, use instance_ui() instead")
		temp_instanced_uis[i] = get_node(i)
	instanced_uis = temp_instanced_uis

func get_child_node_names() -> Array:
	var name_list = []
	for i in get_children():
		name_list.append(i.name)
	return name_list

