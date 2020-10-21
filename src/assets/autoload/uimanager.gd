extends Node

var menus: Dictionary = {"pausemenu": {}}

var openMenus: Array = []

var justClosed: String = ""

signal open_menu

func _ready():
	GameManager.connect("state_changed", self, "state_changed")

#menu data is data to pass to the menu, such as a task identifier
#reInstance is whether or not to recreate the corresponding menu node if it already exists
func open_menu(menuName: String, menuData: Dictionary = {}, reInstance: bool = false):
	#print("signalling to open ", menuName)
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

func _process(_delta):
	#if ui_cancel (most likely esc) and not in menu open pause menu
	if Input.is_action_just_pressed("ui_cancel") and not in_menu() and justClosed != "pausemenu":
		open_menu("pausemenu")
	justClosed = ""
