extends Node

var menus: Dictionary = {"pausemenu": preload("res://assets/ui/pausemenu/pausemenu.tscn")}

signal open_menu

# Called when the node enters the scene tree for the first time.
func _ready():
	GameManager.connect("state_changed", self, "state_changed")
	emit_signal("open_menu", menus["pausemenu"])

func open_menu(menuName):
	pass

func open_task(taskInfo):
	pass

func state_changed(old_state, new_state):
	if new_state == GameManager.State.Normal:
		emit_signal("open_menu", menus["pausemenu"])
