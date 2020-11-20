tool
extends Resource

enum type {task = 0, ui = 1, map = 2}
export(type) var interact_type = 1
var test_type = type.map
#var interact_type: String

#needed to instance new unique task resources in editor
var base_task_interact: Resource = load("res://addons/interactresources/task/task.tres").duplicate()

#depending on which interact type is selected, one of these will be shown in the
#editor as "resource"
var task_resource: Resource = base_task_interact.duplicate()#load("res://addons/interactresources/task/task.tres").duplicate(true)
var ui_resource: Resource = null
var map_resource: Resource = null

var list_abc = true
var abc = "InteractScript"

func init_task():
	pass
#	print(abc)

func _init():
	resource_local_to_scene = true
	print("interact init1")
	pass
	#if Engine.editor_hint:
	#	return

#overrides get, allows for export var groups
func _get(property):
	if not Engine.editor_hint:
		return []
	match property:
		"task":
			return task_resource
		"ui":
			return ui_resource
		"map":
			return map_resource
		"group/subgroup/abc":
			return abc
		"group/list_abc":
			return list_abc

#overrides set, allows for export var groups
func _set(property, value): # overridden
	match property:
#		"interact_type":
#			interact_type = value
#			#property_list_changed_notify()
		"task":
			#if new resource is a task resource
			if value is preload("res://addons/interactresources/task/task.gd"):
				task_resource = value
			else:
				#create new task resource
				task_resource = base_task_interact.duplicate()
		"ui":
			ui_resource = value
		"map":
			map_resource = value
	property_list_changed_notify()
	return true

#overrides _get_property_list, tells editor to show more vars in inspector
func _get_property_list():
	#if not Engine.editor_hint:
	#	return []
	var property_list = []
	
	property_list.append({"name": "task",
		"type": TYPE_OBJECT,
		"usage": PROPERTY_USAGE_DEFAULT,
		"hint": PROPERTY_HINT_RESOURCE_TYPE,
#		"hint_string": "Task",
		})
	property_list.append({"name": "ui",
				"type": TYPE_OBJECT,
				"usage": PROPERTY_USAGE_DEFAULT,
				"hint": PROPERTY_HINT_RESOURCE_TYPE,
#				"hint_string": "Task",
				})
	property_list.append({"name": "map",
				"type": TYPE_OBJECT,
				"usage": PROPERTY_USAGE_DEFAULT,
				"hint": PROPERTY_HINT_RESOURCE_TYPE,
#				"hint_string": "Task",
				})
	return property_list
