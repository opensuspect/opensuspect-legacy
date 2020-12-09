tool
extends Resource

#class_name InteractTask

export(String) var task_text

var item_inputs_on: bool
var item_inputs: PoolStringArray

var item_outputs_on: bool
var item_outputs: PoolStringArray

var map_outputs_on: bool
var map_outputs: Array

var task_outputs_on: bool
var task_outputs: Array

#needed to instance new unique resources in editor
var base_ui_resource: Resource = ResourceLoader.load("res://addons/opensusinteraction/resources/interactui/interactui.tres")
var base_map_resource:Resource = ResourceLoader.load("res://addons/opensusinteraction/resources/interactmap/interactmap.tres")

#changed in the editor via overriding get(), set(), and get_property_list()
var ui_res: Resource = base_ui_resource.duplicate()

#node this task is attached to
var attached_to: Node

#assigned at runtime when registered by TaskManager
var task_id: int
var task_data: Dictionary = {}

var task_registered: bool = false

func complete_task(data: Dictionary = {}) -> bool:
	var temp_interact_data = task_data
	for key in data.keys():
		temp_interact_data[key] = data[key]
	if map_outputs_on:
		for resource in map_outputs:
			resource.interact(attached_to, temp_interact_data)
	return true

func assign_player(player_id: int):
	if not task_data.keys().has("assigned_players"):
		task_data["assigned_players"] = []
	if task_data["assigned_players"].has(player_id):
		return
	task_data["assigned_players"].append(player_id)

func registered(new_id: int, new_task_data: Dictionary):
	task_id = new_id
	for key in new_task_data.keys():
		task_data[key] = new_task_data[key]
	task_registered = true

func get_task_data() -> Dictionary:
	var temp_task_data = task_data
	temp_task_data["task_id"] = task_id
	if task_registered:
		return temp_task_data
	var generated_task_data = gen_task_data()
	for key in generated_task_data.keys():
		temp_task_data[key] = generated_task_data[key]
	return temp_task_data

# generate initial data to send to the task manager, should not be called after it is registered
func gen_task_data() -> Dictionary:
	if task_registered:
		return task_data
	var info: Dictionary = {}
	info["task_text"] = task_text
#	info["item_inputs"] = item_inputs
#	info["item_outputs"] = item_outputs
	info["task_outputs"] = task_outputs
	info["attached_node"] = attached_to
	info["resource"] = self
	#info["ui_resource"] = ui_res
	for key in info.keys():
		task_data[key] = info[key]
	return info

func get_task_id() -> int:
	return task_id

func get_task_state() -> int:
	return task_data["state"]

func set_task_state(new_state: int) -> bool:
	task_data["state"] = new_state
	return true

func interact(_from: Node = null, _interact_data: Dictionary = {}):
	if attached_to == null and _from != null:
		attached_to = _from
	if attached_to == null:
		push_error("InteractTask resource trying to be used with no defined node")
	ui_res.interact(_from, get_task_data())

func init_resource(_from: Node):
	if attached_to == null and _from != null:
		attached_to = _from
	if attached_to == null:
		push_error("InteractTask resource trying to be initiated with no defined node")
	task_id = TaskManager.register_task(self)

func get_interact_data(_from: Node = null) -> Dictionary:
	if attached_to == null and _from != null:
		attached_to = _from
	if attached_to == null:
		push_error("InteractTask resource trying to be used with no defined node")
	return gen_task_data()

func _init():
	#print("task init ", task_name)
	#ensures customizing this resource won't change other resources
	if Engine.editor_hint:
		resource_local_to_scene = true
	#else:
	#	TaskManager.connect("init_tasks", self, "init_task")

#EDITOR STUFF BELOW THIS POINT, DO NOT TOUCH UNLESS YOU KNOW WHAT YOU'RE DOING
#---------------------------------------------------------------------------------------------------
#overrides set(), allows for export var groups and display properties that don't
#match actual var names
func _set(property, value):
	match property:
		"ui_resource":
			#if new resource is a ui interact resource
			if value is preload("res://addons/opensusinteraction/resources/interactui/interactui.gd"):
				ui_res = value
			else:
				#create new ui interact resource
				ui_res = base_ui_resource.duplicate()

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

		"outputs/toggle_map_interactions":
			map_outputs_on = value
			property_list_changed_notify()

		"outputs/output_map_interactions":
			map_outputs = value
			if map_outputs.size() > 0 and map_outputs[-1] == null:
				#print(map_outputs)
				map_outputs[-1] = base_map_resource.duplicate()
			property_list_changed_notify()

		"outputs/toggle_tasks":
			task_outputs_on = value
			property_list_changed_notify()

		"outputs/output_tasks":
			task_outputs = value
			if task_outputs.size() > 0 and task_outputs[-1] == null:
				#print(task_outputs)
				task_outputs[-1] = NodePath("")#base_task_resource.duplicate()
			property_list_changed_notify()
	return true

#overrides get(), allows for export var groups and display properties that don't
#match actual var names
func _get(property):
	match property:
		"ui_resource":
			return ui_res

		"inputs/toggle_items":
			return item_inputs_on
		"inputs/input_items":
			return item_inputs

		"outputs/toggle_items":
			return item_outputs_on
		"outputs/output_items":
			return item_outputs

		"outputs/toggle_map_interactions":
			return map_outputs_on
		"outputs/output_map_interactions":
			return map_outputs

		"outputs/toggle_tasks":
			return task_outputs_on
		"outputs/output_tasks":
			return task_outputs

#overrides get_property_list(), tells editor to show more properties in inspector
func _get_property_list():
	var property_list: Array = []

	property_list.append({"name": "ui_resource",
		"type": TYPE_OBJECT,
		"usage": PROPERTY_USAGE_DEFAULT,
		"hint": PROPERTY_HINT_RESOURCE_TYPE,
		})

	#item input toggle
#	property_list.append({
#		"name": "inputs/toggle_items",
#		"type": TYPE_BOOL,
#		"usage": PROPERTY_USAGE_DEFAULT,
#		"hint": PROPERTY_HINT_NONE,
#		})
#	#item input array field
#	if item_inputs_on:
#		property_list.append({
#		"name": "inputs/input_items",
#		"type": TYPE_STRING_ARRAY,
#		"usage": PROPERTY_USAGE_DEFAULT,
#		"hint": PROPERTY_HINT_NONE,
#		})

	#item output toggle
#	property_list.append({
#		"name": "outputs/toggle_items",
#		"type": TYPE_BOOL,
#		"usage": PROPERTY_USAGE_DEFAULT,
#		"hint": PROPERTY_HINT_NONE,
#		})
#	#item output array field
#	if item_outputs_on:
#		property_list.append({
#		"name": "outputs/output_items",
#		"type": TYPE_STRING_ARRAY,
#		"usage": PROPERTY_USAGE_DEFAULT,
#		"hint": PROPERTY_HINT_NONE,
#		})

	#item output toggle
	property_list.append({
		"name": "outputs/toggle_map_interactions",
		"type": TYPE_BOOL,
		"usage": PROPERTY_USAGE_DEFAULT,
		"hint": PROPERTY_HINT_NONE,
		})
	#item output array field
	if map_outputs_on:
		property_list.append({
		"name": "outputs/output_map_interactions",
		"type": TYPE_ARRAY,
		"usage": PROPERTY_USAGE_DEFAULT,
		"hint": PROPERTY_HINT_NONE,
		})

	#task output toggle
#	property_list.append({
#		"name": "outputs/toggle_tasks",
#		"type": TYPE_BOOL,
#		"usage": PROPERTY_USAGE_DEFAULT,
#		"hint": PROPERTY_HINT_NONE,
#		})
#	if task_outputs_on:
#		property_list.append({
#		"name": "outputs/output_tasks",
#		"type": TYPE_ARRAY,
#		"usage": PROPERTY_USAGE_DEFAULT,
#		"hint": PROPERTY_HINT_DIR,
#		"hint_string": ""
#		})
	return property_list
