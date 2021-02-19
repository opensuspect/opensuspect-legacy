tool
extends Resource

class_name InteractTask

export(String) var task_text

export(int) var random_numbers = 0

var item_inputs_on: bool
var item_inputs: PoolStringArray

var item_outputs_on: bool
var item_outputs: PoolStringArray

var map_outputs_on: bool
var map_outputs: Array

var task_outputs_on: bool
var task_outputs: Array

var is_task_global: bool = false

#needed to instance new unique resources in editor
var base_ui_resource: Resource = ResourceLoader.load("res://addons/opensusinteraction/resources/interactui/interactui.tres")
var base_map_resource:Resource = ResourceLoader.load("res://addons/opensusinteraction/resources/interactmap/interactmap.tres")

#changed in the editor via overriding get(), set(), and get_property_list()
var ui_res: Resource = base_ui_resource.duplicate()

#node this task is attached to
var attached_to: Node

var task_id: int = TaskManager.INVALID_TASK_ID
var task_data: Dictionary = {}
var task_data_player: Dictionary = {}
var task_registered: bool = false

var network_master: int = 1
# function name: rpc mode (puppet, remote, etc.)
var networked_functions: Dictionary = {}
# var name: rpc mode (puppet, remote, etc.)
var networked_properties: Dictionary = {}

# relationships between shown property names and the actual script property name
# properties in this dict are NOT automatically added to editor, they must also be in custom_properties_to_show
# if you want the editor property name to be the same as the script variable name, you do not need to add it to custom_properties
# shown property name: script property name
var custom_properties: Dictionary = {
	"ui_resource": "ui_res", 
	
	"inputs/toggle_items": "item_inputs_on", 
	"inputs/input_items": "item_inputs", 
	
	"outputs/toggle_items": "item_outputs_on", 
	"outputs/output_items": "item_outputs", 
	
	"outputs/toggle_map_interactions": "map_outputs_on", 
	"outputs/output_map_interactions": "map_outputs", 
	
	"outputs/toggle_tasks": "task_outputs_on", 
	"outputs/output_tasks": "task_outputs"
}

# properties to add to the editor with script
# if you want the editor property name to be the same as the script variable name, you do not need to add it to custom_properties
var custom_properties_to_show: PoolStringArray = ["ui_resource", "outputs/toggle_map_interactions", "outputs/output_map_interactions", "is_task_global"]

signal transitioned(old_state, new_state, player_id)
signal task_completed(player_id, data)

# should be called by task UI or an extending script to complete the task
# this function should not add any actual behavior, just relay the attempt to
# 	complete the task to TaskManager
func complete_task(	player_id: int = Network.get_my_id(), 
					data: Dictionary = {}) -> void:
	if not can_complete_task(player_id, data):
		return
	# use virtual function to add custom behavior while retaining the checks or to 
	# 	cancel the attempt to complete this task
	# this is similar behavior to assign_player(), registered(), gen_task_data(), etc.
	# if you want fully custom behavior, override this function instead
	if _complete_task(player_id, data) == false:
		return
	var task_info: Dictionary = TaskManager.gen_task_info(get_task_id(), player_id)
	var new_data: Dictionary = Helpers.merge_dicts(data, get_task_data(player_id))
	TaskManager.complete_task(task_info, new_data)

# override to add custom behavior when an attempt is made to complete the task or to
# 	cancel the attempt
func _complete_task(player_id: int, data: Dictionary):
	pass

# mainly serves as a constant function the TaskManager can call to see if the task is
# 	unofficially completed (all requirements are met, like the time being set correctly
# 	in the clockset task), custom checks can be added in _can_complete_task()
func can_complete_task(player_id: int = Network.get_my_id(), data: Dictionary = {}) -> bool:
	if not is_player_assigned(player_id):
		return false
	var virt_return = _can_complete_task(player_id, data)
	if not virt_return is bool:
		return true
	return virt_return

# while overriding, you must return a bool (whether or not the task will be completed) which
# 	will be relayed to whatever called can_complete_task() (most likely TaskManager)
# this is to add custom checks to see if the task is completed or not
func _can_complete_task(player_id: int, data: Dictionary) -> bool:
	# returns true by default to allow you to control a task purely through the UI script
	# 	to avoid having to make a custom resource. This makes simple tasks much easier
	# 	to make and reduces unnecessary scripts
	return true

# called when a task completion is verified by the server, in Among Us the delay in this step
# 	is hidden by having the UI stay open until the confirmation is received. I believe this
# 	is what currently happens in opensuspect as of 2/18/2021 - TheSecondReal0
# task must be completed somehow during this function, to avoid desync
func task_completed(player_id: int, data: Dictionary):
	# if nothing is explicitly returned, _task_completed() will return null and will not trigger this
	# this allows an extending script to override behavior while retaining the above checks
	# 	by defining _task_completed() and returning false. If you want fully custom 
	# 	behavior, override this function instead
	if _task_completed(player_id, data) == false:
		return
	var temp_interact_data = get_task_data(player_id)
	for key in data.keys():
		temp_interact_data[key] = data[key]
	if map_outputs_on:
		for resource in map_outputs:
			resource.interact(attached_to, temp_interact_data)
	emit_signal("task_completed", player_id, temp_interact_data)
#	complete_task(player_id, data)

# overridden to add custom behavior when the task is completed
# return false while overriding to break execution of task_completed()
func _task_completed(player_id: int, data: Dictionary):
	pass

func assign_player(player_id: int):
	if task_data_player.has(player_id):
		return
	# if nothing is explicitly returned, _assign_player() will return null and will not trigger this
	# this allows an extending script to override behavior while retaining the above checks
	# 	by defining _assign_player() and returning false. If you want fully custom 
	# 	behavior, override this function instead
	# used to add custom behavior when a player is assigned to this task
	if _assign_player(player_id) == false:
		return
	task_data_player[player_id] = task_data.duplicate(true)
	var task_text = task_data["task_text"]
	var data = []
	assert(random_numbers >= 0)
	randomize()
	for i in range(random_numbers):
		data.append(randi())
	#var data: Dictionary = TaskGenerators.call_generator(task_text)
	task_data_player[player_id]["task_data"] = data

# overridden to add custom behavior for when a player is assigned to this task while
# 	retaining the checks implemented in assign_player()
# return false to break out of assign_player() early (before any actions are taken)
func _assign_player(player_id: int):
	pass

func registered(new_task_id: int, new_task_data: Dictionary):
	_registered(new_task_id, new_task_data)
	for key in new_task_data.keys():
		task_data[key] = new_task_data[key]
	task_id = new_task_id
	task_registered = true

func _registered(new_task_id: int, new_task_data: Dictionary):
	pass

# while this function doesn't add any functionality, it does provide a constant
# 	function to call, and we could easily add checks later
# I'm thinking that this could be called by task UIs
func sync_task():
	_sync_task()

# to be overridden by an extending script
func _sync_task():
	pass

# used to get task data after the task has been registered
func get_task_data(player_id: int = Network.get_my_id()) -> Dictionary:
	if task_registered and is_task_global():
		player_id = TaskManager.GLOBAL_TASK_PLAYER_ID
	
	var temp_task_data = task_data
	if task_data_player.has(player_id):
		temp_task_data = task_data_player[player_id]
		
	temp_task_data["task_id"] = task_id
	if not task_registered:
		var generated_task_data = gen_task_data()
		for key in generated_task_data.keys():
			temp_task_data[key] = generated_task_data[key]
	
	var virt_return: Dictionary = _get_task_data(player_id)
	temp_task_data = Helpers.merge_dicts(temp_task_data, virt_return)
	
	return temp_task_data

# override to add custom data when get_task_data() is called
func _get_task_data(player_id: int) -> Dictionary:
	return {}

# generate initial data to send to the task manager, should not be called after it is registered
# this is the starting data used to sync tasks before the game starts
func gen_task_data() -> Dictionary:
#	if task_registered:
#		return task_data
	var info: Dictionary = {}
	info["task_text"] = task_text
#	info["item_inputs"] = item_inputs
#	info["item_outputs"] = item_outputs
	info["task_outputs"] = task_outputs
	info["attached_node"] = attached_to
	info["resource"] = self
	info["is_task_global"] = is_task_global
	#info["ui_resource"] = ui_res
	# so you can override _gen_task_data() and non-destructively add data
	# if you want to remove data, you'd have to override this function
	var virt_info: Dictionary = _gen_task_data()
	for key in virt_info:
		info[key] = virt_info[key]
	for key in info.keys():
		task_data[key] = info[key]
	return info

# meant to be overridden in an extending script to allow adding custom data to task_info
func _gen_task_data() -> Dictionary:
	return {}

func transition(new_state: int, player_id: int = TaskManager.GLOBAL_TASK_PLAYER_ID) -> bool:
	# to add custom behavior/checks before the state is officially changed
	# if _transition() returns false, interpret it to mean the extending script
	# 	doesn't want to transition
	# to remove behavior after this point, you must override this function (make sure
	# 	to emit the "transitioned" signal)
	var virt_return = _transition(new_state, player_id)
	if virt_return is bool and virt_return == false:
		return false
	var old_state = task_data_player[player_id]["state"]
	task_data_player[player_id]["state"] = new_state
	emit_signal("transitioned", old_state, new_state, player_id)
	return true

# override to add custom behavior/checks before the state is officially changed
# this is especially useful if you want to cancel the transition as it would be
# 	much harder to retroactively undo it
# return false to break out of transition() early (this will also cause transition()
# 	to return false to whatever called it, most likely task manager or itself)
func _transition(new_state: int, player_id: int):
	pass

func interact(_from: Node = null, _interact_data: Dictionary = {}):
	if attached_to == null and _from != null:
		attached_to = _from
	if attached_to == null:
		push_error("InteractTask resource trying to be used with no defined node")
	if not task_data_player.has(Network.get_my_id()) and not task_data_player.has(TaskManager.GLOBAL_TASK_PLAYER_ID):
		return
	# if nothing is explicitly returned, _interact() will return null and will not trigger this
	# this check is so an extending script can override interact behavior (while retaining the
	#	above checks) by declaring _interact() and returning false. If you want fully custom 
	# 	behavior, override this function instead
	# this could be used to cancel the interaction or to implement custom behavior, 
	# 	like triggering a map interaction instead of opening a UI
	if _interact(_from, _interact_data) == false:
		return
	ui_res.interact(_from, get_task_data())

# meant to be overridden by an extending script to allow custom behavior when interacted with
func _interact(_from: Node = null, _interact_data: Dictionary = {}):
	pass

func init_resource(_from: Node):
	if attached_to == null and _from != null:
		attached_to = _from
	if attached_to == null:
		push_error("InteractTask resource trying to be initiated with no defined node")
	# if nothing is explicitly returned, _init_resource() will return null and will not trigger this
	# this check is so an inheriting script can override initiation behavior while retaining the
	#	above checks. If you want fully custom behavior, override this function instead
	# I can't think of any reason you wouldn't want to register with the task manager, 
	# 	but the ability to do so couldn't hurt
	# calling the virtual function here also allows the extending script to add custom behavior
	# 	before it is formally registered
	if _init_resource(_from) == false:
		return
	TaskManager.register_task(self)

# meant to be overridden by an extending script to allow custom behavior on resource init
func _init_resource(_from: Node):
	pass

func add_networked_func(function: String, rpc_mode: int):
	networked_functions[function] = rpc_mode

func add_networked_property(property: String, rpc_mode: int):
	networked_properties[property] = rpc_mode

# for consistency with using network functions in nodes
func set_network_master(id: int):
	network_master = id

func task_rset(property: String, value):
	TaskManager.task_rset(property, value, task_id)

func task_rset_id(id: int, property: String, value):
	TaskManager.task_rset_id(id, property, value, task_id)

func receive_task_rset(property: String, value):
	if not property in networked_properties:
		return
	var sender: int = get_rpc_sender_id()
	var rpc_mode: int = networked_properties[property]
	if not is_valid_sender(sender, rpc_mode):
		return
	set(property, value)

# args must be in the form of an array because you can't create functions with variable
# 	arg amounts in gdscript
func task_rpc(function: String, args: Array):
	TaskManager.task_rpc(function, args, task_id)

func task_rpc_id(id: int, function: String, args: Array):
	TaskManager.task_rpc_id(id, function, args, task_id)

func receive_task_rpc(function: String, args: Array):
	if not function in networked_functions:
		return
	var sender: int = get_rpc_sender_id()
	var rpc_mode: int = networked_functions[function]
	if not is_valid_sender(sender, rpc_mode):
		return
	# using callv instead of call because it will translate the array into
	# 	individual arguments
	callv(function, args)

# function to see if we should accept an rpc/rset
func is_valid_sender(sender: int, rpc_mode: int) -> bool:
	var my_id: int = Network.get_my_id()
	match rpc_mode:
		MultiplayerAPI.RPC_MODE_REMOTE:
			return my_id != sender
		MultiplayerAPI.RPC_MODE_MASTER:
			return my_id == network_master
		MultiplayerAPI.RPC_MODE_PUPPET:
			return my_id != network_master
		MultiplayerAPI.RPC_MODE_REMOTESYNC:
			return true
		MultiplayerAPI.RPC_MODE_MASTERSYNC:
			return my_id == network_master
		MultiplayerAPI.RPC_MODE_PUPPETSYNC:
			return my_id != network_master
	return false

# for consistency with using network functions in nodes
func get_rpc_sender_id() -> int:
	# must go through TaskManager because resources do not have access to the scene tree
	# 	by themselves
	return TaskManager.get_tree().get_rpc_sender_id()

# not adding a virtual function for this because the same thing is accomplished by
# overriding _gen_interact_data()
func get_interact_data(_from: Node = null) -> Dictionary:
	if attached_to == null and _from != null:
		attached_to = _from
	if attached_to == null:
		push_error("InteractTask resource trying to be used with no defined node")
	return get_task_data()

func get_task_id() -> int:
	return task_id

func is_task_completed(player_id: int = TaskManager.GLOBAL_TASK_PLAYER_ID) -> bool:
	if not is_player_assigned(player_id):
		return false
	return get_task_state(player_id) == TaskManager.task_state.COMPLETED

func get_task_state(player_id: int = TaskManager.GLOBAL_TASK_PLAYER_ID) -> int:
	if not is_player_assigned(player_id):
		#this player has not been assigned this task
		return TaskManager.task_state.INVALID
	return task_data_player[player_id]["state"]

func is_player_assigned(player_id: int) -> bool:
	if is_task_global():
		return true
	return task_data_player.has(player_id)

func is_task_global() -> bool:
	return task_data["is_task_global"]

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
			return true
		"outputs/output_map_interactions":
			map_outputs = value
			for i in map_outputs.size():
				if map_outputs[i] == null:
					map_outputs[i] = base_map_resource.duplicate()
			property_list_changed_notify()
			return true

	if property in custom_properties.keys():
		set(custom_properties[property], value)
	return true

#overrides get(), allows for export var groups and display properties that don't
#match actual var names
func _get(property):
	if property in custom_properties.keys():
		return get(custom_properties[property])

#overrides get_property_list(), tells editor to show more properties in inspector
func _get_property_list():
	var property_list: Array = []

	for property in custom_properties_to_show:
		if is_property_added(property, property_list):
			continue
		var entry: Dictionary = {}
		var type: int = typeof(get(property))
		if type == TYPE_OBJECT:
			var property_class: String = get(property).get_class()
			entry["hint"] = PROPERTY_HINT_RESOURCE_TYPE
			entry["hint_string"] = property_class
		entry["name"] = property
		entry["type"] = type
		property_list.append(entry)

	return property_list

func is_property_added(property: String, array: Array):
	for dict in array:
		if dict.name == property:
			return true
	return false
