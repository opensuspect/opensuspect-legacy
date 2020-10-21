extends CanvasLayer

var menus: Dictionary = {"pausemenu": preload("res://assets/ui/pausemenu/pausemenu.tscn")}

var instancedMenus: Dictionary = {}

onready var config = ConfigFile.new()

func _ready():
	set_network_master(1)
	UIManager.connect("open_menu", self, "open_menu")
	var err = config.load("user://settings.cfg")
	if err == OK:
		$ColorblindRect.material.set_shader_param("mode", int(config.get_value("general", "colorblind_mode")))

#menu data is data to pass to the menu, such as a task identifier
#reInstance is whether or not to recreate the corresponding menu node if it already exists
func open_menu(menuName: String, menuData: Dictionary = {}, reInstance: bool = false):
	if not menus.keys().has(menuName):
		return
	if reInstance or not instancedMenus.keys().has(menuName):
		instanceMenu(menuName, menuData)
	if menuData != {} and instancedMenus[menuName].get("menuData") != null:
		instancedMenus[menuName].menuData = menuData
	instancedMenus[menuName].open()
	UIManager.menu_opened(menuName)

func instanceMenu(menuName: String, menuData: Dictionary = {}):
	if not menus.keys().has(menuName):
		return
	var newMenu = menus[menuName].instance()
	if menuData != {} and newMenu.get("menuData") != null:
		newMenu.menuData = menuData
	instancedMenus[menuName] = newMenu
	add_child(newMenu)
