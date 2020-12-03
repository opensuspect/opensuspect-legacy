tool
extends Resource

#class_name Interact

enum type {task = 0, ui = 1, map = 2}
export(type) var interact_type

#needed to instance new unique resources in editor
var base_task_resource:Resource = ResourceLoader.load("res://addons/opensusinteraction/resources/interacttask/interacttask.tres")
var base_ui_resource: Resource = ResourceLoader.load("res://addons/opensusinteraction/resources/interactui/interactui.tres")
var base_map_resource:Resource = ResourceLoader.load("res://addons/opensusinteraction/resources/interactmap/interactmap.tres")

#changed in the editor via overriding get(), set(), and get_property_list()
var task_res: Resource = base_task_resource.duplicate()
var ui_res: Resource = base_ui_resource.duplicate()
var map_res: Resource = base_map_resource.duplicate()

var interact_data: Dictionary = {}

#called to execute the interaction this resource is customized for
func interact(_from: Node, interact_data: Dictionary = {}):
	#print(interact_type)
	match interact_type:
		type.task:
			task_res.interact(_from)
		type.ui:
			ui_res.interact(_from, interact_data)
		type.map:
			map_res.interact(_from, interact_data)

func init_resource(_from):
	match interact_type:
		type.task:
			task_res.init_resource(_from)
		type.ui:
			ui_res.init_resource(_from)
		type.map:
			map_res.init_resource(_from)

func get_interact_data(_from: Node = null) -> Dictionary:
	var interact_data: Dictionary = {}
	var res_interact_data: Dictionary = {}
	#print(interact_type)
	match interact_type:
		type.task:
			res_interact_data = task_res.get_interact_data(_from)
		type.ui:
			res_interact_data = ui_res.get_interact_data(_from)
		type.map:
			res_interact_data = map_res.get_interact_data(_from)
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
#overrides set(), for property groups and to display custom/fake properties/vars
func _set(property, value):
#	#add custom stuff to inspector and use this to see what it's trying to do
#	#so you can figure out how to handle it
	#print("setting ", property, " to ", value)
	match property:
		"task_resource":
			#if new resource is a ui interact resource
			if value is preload("res://addons/opensusinteraction/resources/interacttask/interacttask.gd"):
				task_res = value
			else:
				#create new ui interact resource
				task_res = base_task_resource.duplicate()
		"ui_resource":
			#if new resource is a ui interact resource
			if value is preload("res://addons/opensusinteraction/resources/interactui/interactui.gd"):
				ui_res = value
			else:
				#create new ui interact resource
				ui_res = base_ui_resource.duplicate()
		"map_resource":
			#if new resource is a map interact resource
			if value is preload("res://addons/opensusinteraction/resources/interactmap/interactmap.gd"):
				map_res = value
			else:
				#create new map interact resource
				map_res = base_map_resource.duplicate()
	property_list_changed_notify()
	return true

#overrides get(), for property groups and to display custom/fake properties/vars
func _get(property):
	match property:
		"task_resource":
			return task_res
		"ui_resource":
			return ui_res
		"map_resource":
			return map_res

#overrides get_property_list(), tells editor to show custom/fake properties/vars in inspector
func _get_property_list():
#	#if not Engine.editor_hint:
#	#	return []
	var property_list: Array = []
	property_list.append({"name": "task_resource",
		"type": TYPE_OBJECT,
		"usage": PROPERTY_USAGE_DEFAULT,
		"hint": PROPERTY_HINT_RESOURCE_TYPE,
		})
	property_list.append({"name": "ui_resource",
		"type": TYPE_OBJECT,
		"usage": PROPERTY_USAGE_DEFAULT,
		"hint": PROPERTY_HINT_RESOURCE_TYPE,
		})
	property_list.append({"name": "map_resource",
		"type": TYPE_OBJECT,
		"usage": PROPERTY_USAGE_DEFAULT,
		"hint": PROPERTY_HINT_RESOURCE_TYPE,
		})
	return property_list
