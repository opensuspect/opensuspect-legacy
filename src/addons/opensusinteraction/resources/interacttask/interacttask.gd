#tool
extends Resource

#class_name InteractTask

export(String) var task_name

export(String) var ui_name

var item_inputs_on: bool
var item_inputs: PoolStringArray

var item_outputs_on: bool
var item_outputs: PoolStringArray

#needed to instance new unique task resources in editor
var base_task_resource: Resource = ResourceLoader.load("res://addons/opensusinteraction/resources/task/task.tres")

var task_outputs_on: bool
var task_outputs: Array

var list_abc = true
var abc = "InteractTaskScript"

func init_task():
	TaskManager.add_task_resource(self)
	pass

func get_task_info() -> Dictionary:
	return gen_task_info()

func gen_task_info() -> Dictionary:
	var info:Dictionary = {}
	info["task_name"] = task_name
	info["ui_name"] = ui_name
	info["item_inputs"] = item_inputs
	info["item_outputs"] = item_outputs
	info["task_outputs"] = task_outputs
	return info

func _init():
	#ensures customizing this resource won't change other resources
	if Engine.editor_hint:
		resource_local_to_scene = true

#EDITOR STUFF BELOW THIS POINT, DO NOT TOUCH UNLESS YOU KNOW WHAT YOU'RE DOING
#---------------------------------------------------------------------------------------------------
#overrides set(), allows for export var groups and display properties that don't
#match actual var names
func _set(property, value):
	match property:
		"inputs/toggle_items":
			item_inputs_on = value
			property_list_changed_notify()

		"inputs/input_items":
			item_inputs = value

		"outputs/toggle_items":
			item_outputs_on = value
			property_list_changed_notify()

		"outputs/output_items":
			item_outputs = value

		"outputs/toggle_tasks":
			task_outputs_on = value
			property_list_changed_notify()

		"outputs/output_tasks":
			task_outputs = value
			if task_outputs.size() > 0 and task_outputs[-1] == null:
				print("null last task")
				task_outputs[-1] = base_task_resource.duplicate()
			property_list_changed_notify()
	return true

#overrides get(), allows for export var groups and display properties that don't
#match actual var names
func _get(property):
	match property:
		"inputs/toggle_items":
			return item_inputs_on
		"inputs/input_items":
			return item_inputs

		"outputs/toggle_items":
			return item_outputs_on
		"outputs/output_items":
			return item_outputs

		"outputs/toggle_tasks":
			return task_outputs_on
		"outputs/output_tasks":
			return task_outputs

#overrides get_property_list(), tells editor to show more properties in inspector
func _get_property_list():
#	if not Engine.editor_hint:
#		return []
	var property_list: Array = []

	#item input toggle
	property_list.append({
		"name": "inputs/toggle_items",
		"type": TYPE_BOOL,
		"usage": PROPERTY_USAGE_DEFAULT,
		"hint": PROPERTY_HINT_NONE,
		})
	#item input array field
	if item_inputs_on:
		property_list.append({
		"name": "inputs/input_items",
		"type": TYPE_STRING_ARRAY,
		"usage": PROPERTY_USAGE_DEFAULT,
		"hint": PROPERTY_HINT_NONE,
		})

	#item output toggle
	property_list.append({
		"name": "outputs/toggle_items",
		"type": TYPE_BOOL,
		"usage": PROPERTY_USAGE_DEFAULT,
		"hint": PROPERTY_HINT_NONE,
		})
	#item output array field
	if item_outputs_on:
		property_list.append({
		"name": "outputs/output_items",
		"type": TYPE_STRING_ARRAY,
		"usage": PROPERTY_USAGE_DEFAULT,
		"hint": PROPERTY_HINT_NONE,
		})

	#task output toggle
	property_list.append({
		"name": "outputs/toggle_tasks",
		"type": TYPE_BOOL,
		"usage": PROPERTY_USAGE_DEFAULT,
		"hint": PROPERTY_HINT_NONE,
		})
	if task_outputs_on:
		property_list.append({
		"name": "outputs/output_tasks",
		"type": TYPE_ARRAY,
		"usage": PROPERTY_USAGE_DEFAULT,
		"hint": PROPERTY_HINT_NONE,
		"hint_string": ""
		})
	return property_list
