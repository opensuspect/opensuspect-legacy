extends Node

#The task manager is going to assign each task a unique ID, and then assign the ID to a player
#each player will only be sent their task IDs and the info related to their task IDs

#enum task_type {BINARY, WIN, ITEM_OUTPUT, ITEM_INPUT, ITEM_INPUT_OUTPUT, MAP_OUTPUT}

enum task_state {HIDDEN, NOT_STARTED, IN_PROGRESS, COMPLETED}

var task_transitions: Dictionary = {task_state.HIDDEN: [task_state.NOT_STARTED], 
									task_state.NOT_STARTED: [task_state.COMPLETED], 
									task_state.COMPLETED: []
									}

#stores info of each task, for instance it's type (see task_type)
#var tasks: Dictionary = {"clockset": {"type": task_type.BINARY}}
#array with all names of tasks that can be assigned, most likely used for map specific tasks
#var enabled_tasks: Array = ["clockset"]
#dictionary that stores the task IDs corresponding to the tasks assigned to the player
var player_tasks: Dictionary = {}
#stores task info corresponding to task IDs
#format: {<task id>: {name: <task_name>, type: <task type>, state: <task state>, assigned_to: [<network IDs of players task is assigned to>]}
var task_dict: Dictionary = {}

signal init_tasks

func _ready():
	randomize()
	#print(gen_unique_id())

#can't declare new_state as an int, otherwise it would need to default to an int which could cause later problems
func advance_task(task_id: int, new_state = null) -> bool:
	if not get_tree().is_network_server():
		return false
	var task_type: int = task_dict[task_id].type
	var current_state: int = task_dict[task_id].state

	#transition if allowed
	if task_transitions[current_state].empty():
		#if there are no transitions allowed, ex. a completed task
		return false
	if new_state.typeof() == TYPE_INT and task_state.values().has(new_state):
		#if new_state is a state and the state exists
		return transition_task(task_id, new_state)
	#transition task to the first transition listed for that task type in task_transitions
	return transition_task(task_id, task_transitions[task_type][current_state][0])

func transition_task(task_id: int, new_state: int) -> bool:
	if not get_tree().is_network_server():
		return false
	var current_state: int = task_dict[task_id].state
	#if that task type can't transition from current state to new state
	if not task_transitions[current_state].has(new_state):
		return false
	#transition task
	task_dict[task_id].state = new_state
	return true

func new_task(players: Array, task_info: Dictionary):
	#register task
	var new_task_id = register_task(task_info)
	
	#assign task to players
	for i in players:
		assign_task(i, new_task_id)

func register_task(task_info: Dictionary) -> int:
	var new_task_id: int = gen_unique_id()
	var new_task_dict: Dictionary = {"state": task_state.NOT_STARTED, "assigned_to": []}
	#do stuff with task info here
	task_dict[new_task_id] = new_task_dict
	return new_task_id

func assign_task(player_id: int, task_id: int) -> void:
	#create task array for player_id if it doesn't exist
	if not player_tasks.keys().has(player_id):
		player_tasks[player_id] = []
	#add task to list of tasks assigned to player_id
	if not player_tasks[player_id].has(task_id):
		player_tasks[player_id].append(task_id)
	#add player_id to list of players task is assigned to
	if not task_dict[task_id].assigned_to.has(player_id):
		task_dict[task_id].assigned_to.append(player_id)

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
