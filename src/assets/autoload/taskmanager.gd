extends Node

#The task manager is going to assign each task a unique ID, and then assign the ID to a player
#each player will only be sent their task IDs and the info related to their task IDs

#enum task_type {BINARY, WIN, ITEM_OUTPUT, ITEM_INPUT, ITEM_INPUT_OUTPUT, MAP_OUTPUT}

enum task_state {HIDDEN, NOT_STARTED, IN_PROGRESS, COMPLETED}

var task_transitions: Dictionary = {task_state.HIDDEN: [task_state.NOT_STARTED], 
									task_state.NOT_STARTED: [task_state.COMPLETED], 
									task_state.COMPLETED: []
									}

var player_tasks: Dictionary = {}
#stores task info corresponding to task IDs
#format: {<task id>: {name: <task_name>, type: <task type>, state: <task state>, resource: <InteractTask resource>, assigned_players: [<network IDs of players task is assigned to>]}
var task_dict: Dictionary = {}

func _ready():
	randomize()
	#print(gen_unique_id())

func complete_task(task_id: int, data: Dictionary = {}) -> bool:
	print("trying to complete task ", task_id)
	if not does_task_exist(task_id):
		return false
	if not advance_task(task_id, task_state.COMPLETED):
		return false
	return get_task_resource(task_id).complete_task(data)

#can't declare new_state as an int, otherwise it would need to default to an int which could cause later problems
func advance_task(task_id: int, new_state = null) -> bool:
	if not get_tree().is_network_server():
		return false
	if not does_task_exist(task_id):
		return false
	var current_state: int = get_task_data(task_id).state

	#transition if allowed
	if task_transitions[current_state].empty():
		#if there are no transitions allowed, ex. a completed task
		return false
	if typeof(new_state) == TYPE_INT and task_state.values().has(new_state):
		#if new_state is a state and the state exists
		return transition_task(task_id, new_state)
	#transition task to the first transition listed for that task type in task_transitions
	return transition_task(task_id, task_transitions[current_state][0])

func transition_task(task_id: int, new_state: int) -> bool:
	if not get_tree().is_network_server():
		return false
	if not does_task_exist(task_id):
		return false
	var current_state: int = get_task_state(task_id)
	#if that task type can't transition from current state to new state
	if not task_transitions[current_state].has(new_state):
		return false
	#transition task
	return set_task_state(task_id, new_state)

func register_task(task_resource: Resource) -> int:
	var new_task_id: int = gen_unique_id()
	print("registering task with ID ", new_task_id)
	var new_task_data: Dictionary = task_resource.get_task_data()
	new_task_data["state"] = task_state.NOT_STARTED
	new_task_data["assigned_players"] = []
	new_task_data["task_id"] = new_task_id
	#do stuff with task info here
	task_dict[new_task_id] = task_resource
	task_resource.registered(new_task_id, new_task_data)
	print("task registered: ", new_task_data)
	return new_task_id

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

func get_task_data(task_id: int) -> Dictionary:
	if not does_task_exist(task_id):
		return {}
	return get_task_resource(task_id).get_task_data()

func get_task_resource(task_id: int) -> Resource:
	if not does_task_exist(task_id):
		return null
	return task_dict[task_id]

func set_task_state(task_id: int, new_state: int) -> bool:
	if not does_task_exist(task_id):
		return false
	return get_task_resource(task_id).set_task_state(new_state)

func get_task_state(task_id: int):
	if not does_task_exist(task_id):
		return null
	return get_task_resource(task_id).get_task_data()["state"]

func does_task_exist(task_id: int):
	return task_dict.keys().has(task_id)

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
