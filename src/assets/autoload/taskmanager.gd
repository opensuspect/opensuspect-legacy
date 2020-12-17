extends Node

#The task manager is going to assign each task a unique ID, and then assign the ID to a player
#each player will only be sent their task IDs and the info related to their task IDs

signal task_completed(task_id)

#enum task_type {BINARY, WIN, ITEM_OUTPUT, ITEM_INPUT, ITEM_INPUT_OUTPUT, MAP_OUTPUT}

enum task_state {HIDDEN, NOT_STARTED, IN_PROGRESS, COMPLETED}

var task_transitions: Dictionary = {task_state.HIDDEN: [task_state.NOT_STARTED], 
									task_state.NOT_STARTED: [task_state.COMPLETED], 
									task_state.COMPLETED: []
									}

var completed_dict: Dictionary = {}
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

func complete_task(task_id: int, player_id: int, data: Dictionary = {}) -> bool:
	print("trying to complete task ", task_id)
	if not does_task_exist(task_id):
		return false
	if not advance_task(task_id, player_id, task_state.COMPLETED):
		return false
	if player_id != Network.get_my_id():
		completed_dict[player_id][task_id] = true
		return true
	if get_task_resource(task_id).complete_task(player_id, data):
		completed_dict[player_id][task_id] = true
		return true
	return false
	
master func complete_task_remote(task_text: String, player_id: int, data: Dictionary = {}):
	if get_tree().get_rpc_sender_id() != player_id:
		assert(false)
		return
	var task_id = task_dict_name[task_text]
	if complete_task(task_id, player_id, data):
		#the client whose task we just completed needs to be notified
		if player_id != 1:
			rpc_id(player_id, "task_completed", task_text, data)
			emit_signal("task_completed", task_id, player_id)
		else:
			#if we're the server, no need to make network calls
			task_completed(task_text, data)

		
puppet func task_completed(task_text: String, data):
	var task_id = task_dict_name[task_text]
	var player_id = Network.get_my_id()
	complete_task(task_id, player_id, data)
	emit_signal("task_completed", task_id, player_id)

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
		return false
	var rng = RandomNumberGenerator.new()
	for id in Network.peers:
		var tasks_toassign = TaskManager.task_dict
		for task in tasks_toassign.keys():
			rng.randomize()
			if rng.randi_range(-1,0) < 0:
				assign_task(task, id)
				print("task assigned,",tasks_toassign[task])
		if id == 1:
			if TaskManager.player_tasks.has(id):
				print("host tasks assigned", TaskManager.player_tasks[id])
			else:
				print("host tasks assigned -------")
		else:
			var this_peer_tasks = TaskManager.player_tasks[id]
			#assumes that both the client and the server have the same task name
			var this_peer_task_names: Array = []
			#sync the task ids across the network, according to task names
			for task_id in this_peer_tasks:
				this_peer_task_names.append(get_task_resource(task_id).task_text)
			
			rpc_id(id,"get_tasks", this_peer_task_names)
			if player_tasks.has(id):
				print("client tasks assigned", TaskManager.player_tasks[id])
			else:
				print("client tasks assigned -------")
				
remote func get_tasks(tasks_get: Array):
	for task_name in tasks_get:
		assign_task(task_dict_name[task_name], Network.get_my_id())
	print("we got our tasks!")

func assign_task(task_id: int, player_id: int) -> void:
	if not does_task_exist(task_id):
		return
	#create task array for player_id if it doesn't exist
	if not player_tasks.keys().has(player_id):
		player_tasks[player_id] = []
		completed_dict[player_id] = {}
	#add task to list of tasks assigned to player_id
	if not player_tasks[player_id].has(task_id):
		player_tasks[player_id].append(task_id)
		completed_dict[player_id][task_id] = false
	#add player_id to assigned_players in task resource
	task_dict[task_id].assign_player(player_id)

func get_task_data(task_id: int) -> Dictionary:
	if not does_task_exist(task_id):
		return {}
	return get_task_resource(task_id).get_task_data()

func get_task_resource(task_id: int) -> Resource:
	if not does_task_exist(task_id):
		return null
	return task_dict[task_id]
	
func set_task_state(task_id: int, player_id: int, new_state: int) -> bool:
	if not does_task_exist(task_id):
		return false
	return get_task_resource(task_id).set_task_state(player_id, new_state)

func get_task_state(task_id: int, player_id: int):
	if not does_task_exist(task_id):
		return null
	return get_task_resource(task_id).get_task_state(player_id)

func does_task_exist(task_id: int):
	return task_dict.keys().has(task_id)

func is_task_completed(task_id: int, player_id = Network.get_my_id()) -> bool:
	if not does_task_exist(task_id):
		return false
		
	return completed_dict[player_id][task_id]

func gen_unique_id() -> int:
	#task IDs only need to be somewhat random, they MUST be unique
	var used_ids: Array = task_dict.keys() + Network.get_peers()
	var new_id: int = randi()
	while used_ids.has(new_id):
		new_id = randi()
	return new_id

func reset_tasks() -> void:
	player_tasks = {}
	task_dict = {}
	task_dict_name = {}
