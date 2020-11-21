tool
extends Resource

class_name Interact

enum type {task = 0, ui = 1, map = 2}
export(type) var interact_type

#needed to instance new unique task resources in editor
var base_task_interact: Resource = ResourceLoader.load("res://addons/opensusinteraction/resources/task/task.tres")

var task_resource: Resource = base_task_interact.duplicate()
var ui_resource: Resource = null
var map_resource: Resource = null

var list_abc = true
var abc = "InteractScript"

func init_task():
	pass

func _init():
	resource_local_to_scene = true
	#print("interact init1")

#overrides get, allows for export var groups and display properties that don't
#match actual var names
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

#overrides set, allows for export var groups and display properties that don't
#match actual var names
func _set(property, value):
	#add custom stuff to inspector and use this to figure out what the fuck it's trying to do
	#so you can actually handle it
	print("setting ", property, " to ", value)
	match property:
		"task":
			#if new resource is a task resource
			if value is preload("res://addons/opensusinteraction/resources/task/task.gd"):
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
