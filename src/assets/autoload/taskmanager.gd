extends Node

#The task manager is going to assign each task a unique ID, and then assign the ID to a player
#each player will only be sent their task IDs and the info related to their task IDs

signal task_completed(task_info)
signal receive_task_data(task_data)
#enum task_type {BINARY, WIN, ITEM_OUTPUT, ITEM_INPUT, ITEM_INPUT_OUTPUT, MAP_OUTPUT}

# when the task is global, use this id instead of the player id
const GLOBAL_TASK_PLAYER_ID = -255
const INVALID_TASK_ID = -1
enum task_state {HIDDEN, NOT_STARTED, IN_PROGRESS, COMPLETED, INVALID}

var task_transitions: Dictionary = {task_state.HIDDEN: [task_state.NOT_STARTED], 
									task_state.NOT_STARTED: [task_state.COMPLETED], 
									task_state.COMPLETED: []
									}

var player_tasks: Dictionary = {}
#stores task info corresponding to task IDs
#format: {<task id>: {name: <task_name>, type: <task type>, state: <task state>, resource: <InteractTask resource>, assigned_players: [<network IDs of players task is assigned to>]}
var task_dict: Dictionary = {}

var node_path_resource: Dictionary = {}

func _ready():
	#warning-ignore:return_value_discarded
	GameManager.connect("state_changed_priority", self, "_tasks_registered")
	randomize()
	self.set_network_master(1)

const PLAYER_ID_KEY = "player_id"
const TASK_ID_KEY = "task_id"

# GUIs should run this when they think that they have finished the task
func attempt_complete_task(task_info: Dictionary, task_data: Dictionary):
	if not is_task_info_valid(task_info):
		push_error("not sending rpc to server; task_info is not valid")
		assert(false)
		return
	TaskManager.rpc_id(1, "complete_task_remote", task_info, task_data)
	
# completes the task on the server, and notifies the client/s that the tasks
# were compleated
master func complete_task_remote(task_info: Dictionary, task_data: Dictionary = {}):
	if not is_task_info_valid(task_info):
		push_error("provided task_info is not valid" + String(task_info))
		assert(false)
		return
		
	if not is_valid_rpc_sender(task_info[PLAYER_ID_KEY]):
		assert(false)
		return
	
	# TODO Probably should validate the task_data
	
	# A special case, for when the server's player compleated a task
	var completed = false
	if task_info[PLAYER_ID_KEY] == 1:
		completed = complete_task(task_info, task_data)

	var task_id = task_info[TASK_ID_KEY]
	if is_task_global(task_id):
		task_info[PLAYER_ID_KEY] = GLOBAL_TASK_PLAYER_ID
		if completed or complete_task(task_info, task_data):
			rpc("task_completed", task_info, task_data)
			emit_signal("task_completed", task_info)
	# If the task is not global, just advance it, so that we know that
	# the client has completed it
	elif completed or advance_task(task_info, task_state.COMPLETED):
		if task_info[PLAYER_ID_KEY] == 1:
			emit_signal("task_completed", task_info)
		else:
			rpc_id(task_info[PLAYER_ID_KEY], "task_completed", task_info, task_data)

# Called on the client that the task was completed
# or on all the clients if the completed task was global
func complete_task(task_info: Dictionary, data: Dictionary = {}) -> bool:
	if not is_task_info_valid(task_info):
		push_error("provided task_info is not valid")
		assert(false)
		return false
	
	# TODO Probably should check that the data has correct values
	
	var task_id = task_info[TASK_ID_KEY]
	var player_id = task_info[PLAYER_ID_KEY]
	
	print("trying to complete task ", task_id)
	if not does_task_exist(task_id):
		return false
	if not advance_task(task_info, task_state.COMPLETED):
		return false

	return get_task_resource(task_id).complete_task(player_id, data)

# A callback that the server calls when it successfully compleats a task
puppet func task_completed(task_info: Dictionary, data: Dictionary):
	
	if not is_task_info_valid(task_info):
		push_error("provided task_info is not valid")
		assert(false)
		return false
	
	var task_id = task_info[TASK_ID_KEY]
	if not does_task_exist(task_id):
		return
	if is_task_global(task_id):
		task_info[PLAYER_ID_KEY] = GLOBAL_TASK_PLAYER_ID
	if not is_task_completed(task_info):
		#warning-ignore:return_value_discarded
		complete_task(task_info, data)
	emit_signal("task_completed", task_info)

# Clients run this when they want to populate their GUIs
func attempt_request_task_data(task_info: Dictionary):
	if not is_task_info_valid(task_info):
		assert(false)
		return
	TaskManager.rpc_id(1, "request_task_data", Network.get_my_id(), task_info)
	
master func request_task_data(request_player_id: int, task_info: Dictionary):
	if not is_valid_rpc_sender(request_player_id):
		assert(false)
		return
	var player_id = task_info[PLAYER_ID_KEY]
	if player_id != request_player_id and player_id != GLOBAL_TASK_PLAYER_ID:
		assert(false)
		return
	if not is_task_info_valid(task_info):
		assert(false)
		return
	var task_data = get_task_data(task_info)
	if request_player_id != 1:
		task_data = networkfy_task_data(task_data)
		rpc_id(request_player_id, "receive_task_data", task_data)
	else:
		receive_task_data(task_data)

# Callback with the requested task data
puppet func receive_task_data(task_data: Dictionary):
	emit_signal("receive_task_data", task_data)

# removes parameters from task data that shouldn't be sent over network
func networkfy_task_data(task_data: Dictionary) -> Dictionary:
	var keys_to_erase = ["task_outputs", "attached_node", "resource"]
	var filtered: Dictionary = task_data.duplicate(true)
	for key_to_erase in keys_to_erase:
		#warning-ignore:return_value_discarded
		filtered.erase(key_to_erase)
	
	return filtered
	
#can't declare new_state as an int, otherwise it would need to default to an int which could cause later problems
func advance_task(task_info: Dictionary, new_state: int) -> bool:
	if not is_task_info_valid(task_info):
		return false
	var task_id = task_info[TASK_ID_KEY]
	var player_id = task_info[PLAYER_ID_KEY]
	if not does_task_exist(task_id):
		return false
	var current_state: int = get_task_resource(task_id).get_task_state(player_id)

	#transition if allowed
	if task_transitions[current_state].empty():
		#if there are no transitions allowed, ex. a completed task
		return false
	if typeof(new_state) == TYPE_INT and task_state.values().has(new_state):
		#if new_state is a state and the state exists
		return transition_task(task_info, new_state)
	#transition task to the first transition listed for that task type in task_transitions
	return transition_task(task_info, task_transitions[current_state][0])

func transition_task(task_info: Dictionary, new_state: int) -> bool:
	if not is_task_info_valid(task_info):
		return false
	var current_state: int = get_task_state(task_info)
	#if that task type can't transition from current state to new state
	if not task_transitions[current_state].has(new_state):
		return false
	#transition task
	return set_task_state(task_info, new_state)

func register_task(task_resource: Resource):
	var path = Helpers.get_absolute_path_to(task_resource.attached_to)
	node_path_resource[path] = task_resource
	
	if not get_tree().is_network_server():
		return
	
	var task_id = task_resource.get_task_id()

	if task_id == INVALID_TASK_ID:
		task_id = gen_unique_id()
		#node_path_id[path] = task_id
	
	var new_task_data: Dictionary = task_resource.get_task_data()
	new_task_data["state"] = task_state.NOT_STARTED
	if not assign_task_data(task_resource, task_id, new_task_data):
		assert(false)
		return

func _tasks_registered(_old_state, new_state, priority):
	if not get_tree().is_network_server():
		return
	if new_state != GameManager.State.Normal:
		return
	if priority != 2:
		return
	var registered_tasks = []
	for task_resource in task_dict.values():
		var task = {}
		task["path"] = Helpers.get_absolute_path_to(task_resource.attached_to)
		task["task_id"] = task_resource.get_task_id()
		task["task_data"] = task_resource.get_task_data()
		registered_tasks.append(task)
	rpc("assign_task_data_client", registered_tasks)
	
puppet func assign_task_data_client(registered_tasks: Array):
	for task in registered_tasks:
		var path = task["path"]
		var task_id = task["task_id"]
		var task_data = task["task_data"]
		if not node_path_resource.has(path):
			assert(false)
			continue
		var task_resource: Resource = node_path_resource[path]
		if not assign_task_data(task_resource, task_id, task_data):
			assert(false)
			continue

func assign_task_data(task_resource: Resource, task_id: int, new_data: Dictionary) -> bool:
	print("registering task with ID ", task_id)
	#do stuff with task info here
	if task_dict.has(task_id):
		push_error("Task ID " + String(task_id) + " already registered")
		return false
	task_dict[task_id] = task_resource

	task_resource.registered(task_id, new_data)
	print("task registered: ", new_data)
	return true
	
# called by the player manager while assigning roles
func assign_tasks():
	if not get_tree().is_network_server():
		return
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	
	var tasks_to_assign = TaskManager.task_dict
	# assign global tasks
	for task in tasks_to_assign:
		if not is_task_global(task):
			continue
		if rng.randi_range(-1,0) < 0:
			assign_task(gen_task_info(task, GLOBAL_TASK_PLAYER_ID))
			print("global task assigned,",tasks_to_assign[task])
	# assign regular tasks
	for id in Network.peers:
		for task in tasks_to_assign.keys():
			if is_task_global(task):
				continue
			if rng.randi_range(-1,0) < 0:
				assign_task(gen_task_info(task, id))
				print("task assigned,",tasks_to_assign[task])

		var tasks_to_send 	= get_tasks_to_send(id)

		if id == 1:
			print("host tasks assigned ", tasks_to_send)
		elif not tasks_to_send.empty():
			rpc_id(id,"get_tasks", tasks_to_send)
			print("client " + String(id) + " tasks assigned ", tasks_to_send)

puppet func get_tasks(tasks_get: Array):
	for task_info in tasks_get:
		if is_task_info_valid(task_info):
			assign_task(task_info)
	print("we got our tasks!")

func get_tasks_to_send(player_id: int) -> Array:
	var arr = []
	arr += get_player_tasks(player_id)
	arr += get_player_tasks(GLOBAL_TASK_PLAYER_ID)
	return arr
	
func get_player_tasks(player_id: int) -> Array:
	var arr = []
	if not player_tasks.has(player_id):
		return arr
	for task_id in player_tasks[player_id]:
		arr.append(gen_task_info(task_id, player_id))
	return arr

func assign_task(task_info: Dictionary) -> void:
	if not is_task_info_valid(task_info):
		return
		
	var player_id = task_info[PLAYER_ID_KEY]
	var task_id = task_info[TASK_ID_KEY]
	#create task array for player_id if it doesn't exist
	if not player_tasks.keys().has(player_id):
		player_tasks[player_id] = []
	#add task to list of tasks assigned to player_id
	if not player_tasks[player_id].has(task_id):
		player_tasks[player_id].append(task_id)
	#add player_id to assigned_players in task resource
	task_dict[task_id].assign_player(player_id)

func get_task_data(task_info: Dictionary) -> Dictionary:
	if not is_task_info_valid(task_info):
		return {}
	var task_id = task_info[TASK_ID_KEY]
	var player_id = task_info[PLAYER_ID_KEY]
	return get_task_resource(task_id).get_task_data(player_id)

func get_task_resource(task_id: int) -> Resource:
	if not does_task_exist(task_id):
		return null
	return task_dict[task_id]
	
func set_task_state(task_info: Dictionary, new_state: int) -> bool:
	if not is_task_info_valid(task_info):
		return false
	var task_id = task_info[TASK_ID_KEY]
	var player_id = task_info[PLAYER_ID_KEY]
	return get_task_resource(task_id).set_task_state(player_id, new_state)

func get_task_state(task_info: Dictionary) -> int:
	if not is_task_info_valid(task_info):
		return task_state.INVALID
	var task_id = task_info[TASK_ID_KEY]
	var player_id = task_info[PLAYER_ID_KEY]
	return get_task_resource(task_id).get_task_state(player_id)

func does_task_exist(task_id: int):
	return task_id != INVALID_TASK_ID and task_dict.has(task_id)

func is_task_completed(task_info: Dictionary) -> bool:
	if not is_task_info_valid(task_info):
		return false
	var task_state = get_task_state(task_info)
	return task_state == TaskManager.task_state.COMPLETED

func is_task_global(task_id: int) -> bool:
	if not does_task_exist(task_id):
		return false
	return get_task_resource(task_id).is_task_global()

func is_task_info_valid(info: Dictionary, keys: Array = [PLAYER_ID_KEY, TASK_ID_KEY]) -> bool:
	for key in keys:
		if not info.has(key):
			push_error("provided info dictionary is missing a " + key + "key")
			return false
			
	# ensure that the task is valid
	if not does_task_exist(info[TASK_ID_KEY]):
		var task_id = String(info[TASK_ID_KEY])
		push_error("provided task " + task_id + " doesn't exist")
		return false
		
	if not Network.peers.has(info[PLAYER_ID_KEY]):
		var peer = String(info[PLAYER_ID_KEY])
		# this only works, since we have validated the task before
		if not is_task_global(info[TASK_ID_KEY]):
			push_error("provided player id: " + peer + " is not one of our peers")
			return false
		elif info[PLAYER_ID_KEY] != GLOBAL_TASK_PLAYER_ID:
			var gtpid = String(GLOBAL_TASK_PLAYER_ID)
			push_error("provided global task player id: " + peer + " is not " + gtpid)
			return false
		
	return true

func gen_unique_id() -> int:
	#task IDs only need to be somewhat random, they MUST be unique
	var used_ids: Array = task_dict.keys() + Network.get_peers()
	var new_id: int = randi()
	while used_ids.has(new_id):
		new_id = randi()
	return new_id

func gen_task_info(task_id: int, player_id: int = Network.get_my_id()) -> Dictionary:
	var task_info = {TASK_ID_KEY: task_id, PLAYER_ID_KEY: player_id}
	if not is_task_info_valid(task_info):
		push_error("Can't generate an invalid task_info " + String(task_info))
		assert(false)
		return {}
	return task_info

func reset_tasks() -> void:
	player_tasks = {}
	task_dict = {}
	#task_dict_name = {}
	
	
	
	
func is_valid_rpc_sender(player_id: int) -> bool:
	var rpc_sender = get_tree().get_rpc_sender_id()
	if rpc_sender != player_id:
		push_error("provided player id " + String(player_id) +", is not the same as the rpc sender id " + String(rpc_sender))
		return false
	return true
