extends CanvasLayer

var menus: Dictionary = {"pausemenu": preload("res://assets/ui/pausemenu/pausemenu.tscn")}

onready var config = ConfigFile.new()

func _ready():
	set_network_master(1)
	UIManager.connect("open_menu", self, "open_menu")
	var err = config.load("user://settings.cfg")
	if err == OK:
		$ColorblindRect.material.set_shader_param("mode", int(config.get_value("general", "colorblind_mode")))

func open_menu(menuName):
	get_node("menuName")
