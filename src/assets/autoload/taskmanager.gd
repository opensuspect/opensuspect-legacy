extends Node

#The task manager is going to assign each task a unique ID, and then assign the ID to a player
#each player will only be sent their task IDs and the info related to their task IDs

signal task_completed(task_id)
signal receive_task_data(ui_data)
#enum task_type {BINARY, WIN, ITEM_OUTPUT, ITEM_INPUT, ITEM_INPUT_OUTPUT, MAP_OUTPUT}

const GLOBAL_TASK_ID = -255
const INVALID_TASK_ID = -1
enum task_state {HIDDEN, NOT_STARTED, IN_PROGRESS, COMPLETED}

var task_transitions: Dictionary = {task_state.HIDDEN: [task_state.NOT_STARTED], 
									task_state.NOT_STARTED: [task_state.COMPLETED], 
									task_state.COMPLETED: []
									}

var player_tasks: Dictionary = {}
#stores task info corresponding to task IDs
#format: {<task id>: {name: <task_name>, type: <task type>, state: <task state>, resource: <InteractTask resource>, assigned_players: [<network IDs of players task is assigned to>]}
var task_dict: Dictionary = {}
#format: {<task_text>: *same as the player_tasks*
#used for task resource lookup by name, for network syncing
var task_dict_name: Dictionary = {}

func _ready():
	randomize()
	self.set_network_master(1)
	#print(gen_unique_id())


master func complete_task_remote(task_text: String, player_id: int, data: Dictionary = {}):
	if get_tree().get_rpc_sender_id() != player_id:
		assert(false)
		return
	var task_id = get_task_id_by_name(task_text)
	if not does_task_exist(task_id):
		return
	# TODO Probably should check & filter the data somehow
	var id = player_id
	
	var completed = false
	if player_id == 1:
		completed = complete_task(task_id, id, data)
	# If the task is global, complete it(so that the ui gets updated)
	if is_task_global(task_id):
		id = GLOBAL_TASK_ID
		if completed or complete_task(task_id, id, data):
			rpc("task_completed", task_text, id, data)
			emit_signal("task_completed", task_id, id)
	# If the task is not global, just advance it, so that we know that
	# the client completed it
	# This does mean that only global tasks will spawn items
	elif completed or advance_task(task_id, id, task_state.COMPLETED):
		rpc_id(player_id, "task_completed", task_text, id, data)
		emit_signal("task_completed", task_id, id)
func complete_task(task_id: int, player_id: int, data: Dictionary = {}) -> bool:
	print("trying to complete task ", task_id)
	if not does_task_exist(task_id):
		return false
	if not advance_task(task_id, player_id, task_state.COMPLETED):
		return false
	if get_task_resource(task_id).complete_task(player_id, data): 
		return true
	return false

puppet func task_completed(task_text: String, player_id: int, data: Dictionary):
	var task_id = get_task_id_by_name(task_text)
	if not does_task_exist(task_id):
		return
	if is_task_global(task_id):
		player_id = GLOBAL_TASK_ID
	if not is_task_completed(task_id, player_id):
		# hopefuly the PR#264 will allow the server to notify the map node,
		# so that we don't ever have to complete the tasks on the clientside too
		# intsead we could just
		# advance_task(task_id, player_id, task_state.COMPLETED):
		#warning-ignore:return_value_discarded
		complete_task(task_id, player_id, data)
	emit_signal("task_completed", task_id, player_id)
	
master func request_task_data(task_text: String, player_id: int):
	if get_tree().get_rpc_sender_id() != player_id:
		assert(false)
		return
	var task_id = get_task_id_by_name(task_text)
	if not does_task_exist(task_id):
		assert(false)
		return
	var task_data = get_task_data(task_id, player_id)
	if player_id != 1:
		task_data = networkfy_task_data(task_data)
		rpc_id(player_id, "receive_task_data", task_text, task_data)
	else:
		receive_task_data(task_text, task_data)
		
puppet func receive_task_data(task_text: String, task_data: Dictionary):
	var task_id = get_task_id_by_name(task_text)
	if not does_task_exist(task_id):
		assert(false)
		return
	emit_signal("receive_task_data", task_id, task_data)

#removes parameters from task data that shouldn't be sent over network
func networkfy_task_data(task_data: Dictionary) -> Dictionary:
	var keys_to_erase = ["task_id", "task_outputs", "attached_node", "resource"]
	var filtered: Dictionary = task_data.duplicate(true)
	for key_to_erase in keys_to_erase:
		#warning-ignore:return_value_discarded
		filtered.erase(key_to_erase)
	
	return filtered
#can't declare new_state as an int, otherwise it would need to default to an int which could cause later problems
func advance_task(task_id: int, player_id: int, new_state: int) -> bool:
	if not does_task_exist(task_id):
		return false
	var current_state: int = get_task_resource(task_id).get_task_state(player_id)

	#transition if allowed
	if task_transitions[current_state].empty():
		#if there are no transitions allowed, ex. a completed task
		return false
	if typeof(new_state) == TYPE_INT and task_state.values().has(new_state):
		#if new_state is a state and the state exists
		return transition_task(task_id, player_id, new_state)
	#transition task to the first transition listed for that task type in task_transitions
	return transition_task(task_id, player_id, task_transitions[current_state][0])

func transition_task(task_id: int, player_id: int, new_state: int) -> bool:
	if not does_task_exist(task_id):
		return false
	var current_state: int = get_task_state(task_id, player_id)
	#if that task type can't transition from current state to new state
	if not task_transitions[current_state].has(new_state):
		return false
	#transition task
	return set_task_state(task_id, player_id, new_state)

func register_task(task_resource: Resource) -> int:
	var new_task_id: int = gen_unique_id()
	print("registering task with ID ", new_task_id)
	var new_task_data: Dictionary = task_resource.get_task_data()
	new_task_data["state"] = task_state.NOT_STARTED
	#new_task_data["assigned_players"] = {}
	new_task_data["task_id"] = new_task_id
	#do stuff with task info here
	task_dict[new_task_id] = task_resource
	# Damjan's syncyng hack fails if two tasks have the same name
	assert(not task_dict_name.has(task_resource.task_text))
	
	task_dict_name[task_resource.task_text] = new_task_id
	task_resource.registered(new_task_id, new_task_data)
	print("task registered: ", new_task_data)
	return new_task_id
	
#called by the player manager while assigning roles
func assign_tasks():
	if not get_tree().is_network_server():
		return
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	
	var tasks_to_assign = TaskManager.task_dict
	#assign global tasks
	for task in tasks_to_assign:
		if is_task_global(task):
			if true or rng.randi_range(-1,0) < 0:
				assign_task(task, GLOBAL_TASK_ID)
				print("global task assigned,",tasks_to_assign[task])
	for id in Network.peers:
		for task in tasks_to_assign.keys():
			if is_task_global(task):
				continue
				
			if true or rng.randi_range(-1,0) < 0:
				assign_task(task, id)
				print("task assigned,",tasks_to_assign[task])
				
		var tasks_to_send 	= player_task_arr_id_to_dict_name(GLOBAL_TASK_ID)
		tasks_to_send 		= player_task_arr_id_to_dict_name(id, tasks_to_send)

		if id == 1:
			print("host tasks assigned ", tasks_to_send)
		elif not tasks_to_send.empty():
			rpc_id(id,"get_tasks", tasks_to_send)
			print("client tasks assigned ", tasks_to_send)

func player_task_arr_id_to_dict_name(	player_id: int,
										dict: Dictionary = {}) -> Dictionary:
	if not player_tasks.has(player_id):
		return dict
	for task_id in player_tasks[player_id]:
		var task_text = get_task_resource(task_id).task_text
		dict[task_text] = player_id
	return dict
				
remote func get_tasks(tasks_get: Dictionary):
	for task_name in tasks_get.keys():
		assign_task(task_dict_name[task_name], tasks_get[task_name])
	print("we got our tasks!")

func assign_task(task_id: int, player_id: int) -> void:
	if not does_task_exist(task_id):
		return
	#create task array for player_id if it doesn't exist
	if not player_tasks.keys().has(player_id):
		player_tasks[player_id] = []
	#add task to list of tasks assigned to player_id
	if not player_tasks[player_id].has(task_id):
		player_tasks[player_id].append(task_id)
	#add player_id to assigned_players in task resource
	task_dict[task_id].assign_player(player_id)

func get_task_data(task_id: int, player_id: int = Network.get_my_id()) -> Dictionary:
	if not does_task_exist(task_id):
		return {}
	return get_task_resource(task_id).get_task_data(player_id)

func get_task_resource(task_id: int) -> Resource:
	if not does_task_exist(task_id):
		return null
	return task_dict[task_id]
	
func set_task_state(task_id: int, player_id: int, new_state: int) -> bool:
	if not does_task_exist(task_id):
		return false
	return get_task_resource(task_id).set_task_state(player_id, new_state)

func get_task_id_by_name(task_text: String) -> int:
	if not task_dict_name.has(task_text):
		return INVALID_TASK_ID
	return task_dict_name[task_text]

func get_task_state(task_id: int, player_id: int):
	if not does_task_exist(task_id):
		return null
	return get_task_resource(task_id).get_task_state(player_id)

func does_task_exist(task_id: int):
	return task_dict.keys().has(task_id)

func is_task_completed(task_id: int, player_id) -> bool: # = Network.get_my_id()
	if not does_task_exist(task_id):
		return false
	return get_task_state(task_id, player_id) == task_state.COMPLETED
	#return completed_dict[player_id][task_id]

func is_task_global(task_id: int) -> bool:
	if not does_task_exist(task_id):
		return false
	return get_task_resource(task_id).is_task_global()
	
func gen_unique_id() -> int:
	#task IDs only need to be somewhat random, they MUST be unique
	var used_ids: Array = task_dict.keys() + Network.get_peers() + [GLOBAL_TASK_ID, INVALID_TASK_ID]
	var new_id: int = randi()
	while used_ids.has(new_id):
		new_id = randi()
	return new_id

func reset_tasks() -> void:
	player_tasks = {}
	task_dict = {}
	task_dict_name = {}
