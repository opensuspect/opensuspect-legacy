#tool
extends Resource

#SHOULD NOT BE USED

#class_name Interact

enum type {task = 0, ui = 1, map = 2}
#export(type) var interact_type
var interact_type: String

#needed to instance new unique task resources in editor
var base_task_interact: Resource = ResourceLoader.load("res://assets/common/resources/interact/taskinteract/taskinteract.tres")
var task_resource: Resource = base_task_interact.duplicate(true)
var ui_resource: Resource = null
var map_resource: Resource = null

var list_abc = true
var abc = "InteractScript"

func init_task():
	print(TaskManager.gen_unique_id())
	pass
#	print(abc)

func _init():
	print(TaskManager.gen_unique_id())
	resource_local_to_scene = true
	pass
	#if Engine.editor_hint:
	#	return

#overrides get, allows for export var groups
func _get(property):
	if not Engine.editor_hint:
		return []
	match property:
		"resource":
			match interact_type:
				"Task":
					return task_resource
				"Ui":
					return ui_resource
				"Map":
					return map_resource
		"group/subgroup/abc":
			return abc
		"group/list_abc":
			return list_abc

#overrides set, allows for export var groups
func _set(property, value): # overridden
	if not Engine.editor_hint:
		return []
	match property:
		"interact_type":
			interact_type = value
			property_list_changed_notify()
		"resource":
			#interact_type = value
			match interact_type:
				"Task":
					task_resource = value
				"Ui":
					ui_resource = value
				"Map":
					map_resource = value
			property_list_changed_notify()

	property_list_changed_notify()
	return true

#overrides _get_property_list, tells editor to show more vars in inspector
func _get_property_list():
	#if not Engine.editor_hint:
	#	return []
	var property_list = []
	
	property_list.append({
		"name": "interact_type",
		"type": TYPE_STRING,
		"usage": PROPERTY_USAGE_DEFAULT,
		"hint": PROPERTY_HINT_ENUM,
		#don't how to have it not spit "Cannot get class 'TaskInteract'.
		"hint_string": "Task,Ui,Map",# if ClassDB.class_exists("TaskInteract") else class_list,
		})
	
	property_list.append({
		"name": "resource",
		"type": TYPE_OBJECT,
		"usage": PROPERTY_USAGE_DEFAULT,
		"hint": PROPERTY_HINT_RESOURCE_TYPE,
		"hint_string": "Task",
		})

	return property_list
