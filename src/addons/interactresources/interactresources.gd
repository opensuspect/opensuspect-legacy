tool
extends EditorPlugin


func _enter_tree():
	add_custom_type("Interact", "Resource", preload("res://addons/interactresources/interact.gd"), preload("res://addons/interactresources/object.svg"))
	add_custom_type("Task", "Resource", preload("res://addons/interactresources/task/task.gd"), preload("res://addons/interactresources/object.svg"))


func _exit_tree():
	remove_custom_type("Task")
