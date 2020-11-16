extends CanvasLayer

var menus: Dictionary = UIManager.menus

var instancedMenus: Dictionary = {}

onready var config = ConfigFile.new()

func _ready():
	set_network_master(1)
# warning-ignore:return_value_discarded
	UIManager.connect("open_menu", self, "open_menu")
	var err = config.load("user://settings.cfg")
	if err == OK:
		$ColorblindRect.material.set_shader_param(
			"mode", config.get_value("general", "colorblind_mode")
		)

	#TODO: better system for auto spawning UIs
	instance_menu("chatbox")
	instance_menu("interactui")

#menu data is data to pass to the menu, such as a task identifier
#reInstance is whether or not to recreate the corresponding menu node if it already exists
func open_menu(menuName: String, menuData: Dictionary = {}, reInstance: bool = false):
	if not menus.keys().has(menuName):
		return
	if reInstance or not instancedMenus.keys().has(menuName):
		instance_menu(menuName, menuData)
	if menuData != {} and instancedMenus[menuName].get("menuData") != null:
		instancedMenus[menuName].menuData = menuData
	var current_menu = instancedMenus[menuName]
	#call open on a lower class, handles ui system integration
	current_menu.base_open()
	#call open on the inherited class, most likely the script attached to a given task or menu
	if current_menu.has_method("open"):
		current_menu.open()

func close_menu(menuName: String):
	if not instancedMenus.has(menuName):
		return
	var current_menu = instancedMenus[menuName]
	#call close on a lower class, handles ui system integration
	current_menu.base_close()
	#call close on the inherited class, most likely the script attached to a given task or menu
	if current_menu.has_method("close"):
		current_menu.close()

func instance_menu(menuName: String, menuData: Dictionary = {}):
	if not menus.keys().has(menuName):
		return
	var newMenu = menus[menuName].scene.instance()
	if menuData != {} and newMenu.get("menuData") != null:
		newMenu.menuData = menuData
	instancedMenus[menuName] = newMenu
	add_child(newMenu)
