tool
extends EditorPlugin

#custom resources
var interact_resource_script
var interactmap_resource_script
var interactui_resource_script
var task_resource_script

#icons
var object_icon

func _enter_tree():
	#load custom resources
	interact_resource_script = preload("res://addons/opensusinteraction/resources/interact/interact.gd")
	interactmap_resource_script = preload("res://addons/opensusinteraction/resources/interactmap/interactmap.gd")
	task_resource_script = preload("res://addons/opensusinteraction/resources/interacttask/interacttask.gd")
	interactui_resource_script = preload("res://addons/opensusinteraction/resources/interactui/interactui.gd")
	
	#load icons
	object_icon = preload("res://addons/opensusinteraction/icons/object.svg")
	
	#add custom resources
	add_custom_type("Interact", "Resource", interact_resource_script, object_icon)
	add_custom_type("InteractMap", "Resource", interactmap_resource_script, object_icon)
	add_custom_type("InteractTask", "Resource", task_resource_script, object_icon)
	add_custom_type("InteractUI", "Resource", interactui_resource_script, object_icon)

func _exit_tree():
	remove_custom_type("Interact")
	remove_custom_type("InteractMap")
	remove_custom_type("InteractTask")
	remove_custom_type("InteractUI")
