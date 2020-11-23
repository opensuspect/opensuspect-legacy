tool
extends Resource

class_name Interact

enum type {task = 0, ui = 1, map = 2}
export(type) var interact_type

#needed to instance new unique resources in editor
var base_task_resource: Resource = ResourceLoader.load("res://addons/opensusinteraction/resources/task/task.tres")
var base_ui_resource: Resource = ResourceLoader.load("res://addons/opensusinteraction/resources/interactui/interactui.tres")
var base_map_resource:Resource = ResourceLoader.load("res://addons/opensusinteraction/resources/interactmap/interactmap.tres")

#changed in the editor via overriding get(), set(), and get_property_list()
export var task_resource: Resource = base_task_resource.duplicate()
export var ui_resource: Resource = base_ui_resource.duplicate()
export var map_resource: Resource = base_map_resource.duplicate()

var interact_data: Dictionary = {}

#called to execute the interaction this resource is customized for
func interact(_from: Node):
	match interact_type:
		type.task:
			pass
			#task_resource.interact(_from)
		type.ui:
			ui_resource.interact(_from)
		type.map:
			map_resource.interact(_from)

func get_interact_data(_from: Node = null) -> Dictionary:
	var interact_data: Dictionary = {}
	var res_interact_data: Dictionary = {}
	match interact_type:
		type.task:
			pass
			#res_interact_data = task_resource.get_interact_data()
		type.ui:
			res_interact_data = ui_resource.get_interact_data(_from)
		type.map:
			res_interact_data = map_resource.get_interact_data(_from)
	for i in res_interact_data.keys():
		interact_data[i] = res_interact_data[i]
	if not interact_data.keys().has("interact_type"):
		interact_data["interact_type"] = interact_type
	return interact_data

func _init():
	#ensures customizing this resource won't change other resources
	if Engine.editor_hint:
		resource_local_to_scene = true

#EDITOR STUFF BELOW THIS POINT, DO NOT TOUCH UNLESS YOU KNOW WHAT YOU'RE DOING
#---------------------------------------------------------------------------------------------------
#overrides set(), allows for export var groups and display properties that don't
#match actual var names
func _set(property, value):
#	#add custom stuff to inspector and use this to figure out what it's trying to do
#	#so you can figure out how to handle it
#	#print("setting ", property, " to ", value)
	match property:
#		"task":
#			#if new resource is a task resource
#			if value is preload("res://addons/opensusinteraction/resources/task/task.gd"):
#				task_resource = value
#			else:
#				#create new task resource
#				task_resource = base_task_resource.duplicate()
#		"ui":
#			#if new resource is a ui interact resource
#			if value is preload("res://addons/opensusinteraction/resources/interactui/interactui.gd"):
#				ui_resource = value
#			else:
#				#create new ui interact resource
#				ui_resource = base_ui_resource.duplicate()
#		"map":
#			#if new resource is a map interact resource
#			if value is preload("res://addons/opensusinteraction/resources/interactmap/interactmap.gd"):
#				map_resource = value
#			else:
#				#create new map interact resource
#				map_resource = base_map_resource.duplicate()
		"task_resource":
			#if new resource is a task resource
			if value is preload("res://addons/opensusinteraction/resources/task/task.gd"):
				task_resource = value
			else:
				#create new task resource
				task_resource = base_task_resource.duplicate()
		"ui_resource":
			#if new resource is a ui interact resource
			if value is preload("res://addons/opensusinteraction/resources/interactui/interactui.gd"):
				ui_resource = value
			else:
				#create new ui interact resource
				ui_resource = base_ui_resource.duplicate()
		"map_resource":
			#if new resource is a map interact resource
			if value is preload("res://addons/opensusinteraction/resources/interactmap/interactmap.gd"):
				map_resource = value
			else:
				#create new map interact resource
				map_resource = base_map_resource.duplicate()
#	property_list_changed_notify()
#	return true

#overrides get(), allows for export var groups and display properties that don't
#match actual var names
#func _get(property):
#	if not Engine.editor_hint:
#		return []
#	match property:
#		"task":
#			return task_resource
#		"ui":
#			return ui_resource
#		"map":
#			return map_resource

#overrides get_property_list(), tells editor to show more vars in inspector
func _get_property_list():
	#if not Engine.editor_hint:
	#	return []
	var property_list: Array = []
#	property_list.append({"name": "task",
#		"type": TYPE_OBJECT,
#		"usage": PROPERTY_USAGE_DEFAULT,
#		"hint": PROPERTY_HINT_RESOURCE_TYPE,
#		})
#	property_list.append({"name": "ui",
#				"type": TYPE_OBJECT,
#				"usage": PROPERTY_USAGE_DEFAULT,
#				"hint": PROPERTY_HINT_RESOURCE_TYPE,
#				})
#	property_list.append({"name": "map",
#				"type": TYPE_OBJECT,
#				"usage": PROPERTY_USAGE_DEFAULT,
#				"hint": PROPERTY_HINT_RESOURCE_TYPE,
#				})
	return property_list
