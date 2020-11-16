extends Node

#The task manager is going to assign each task a unique ID, and then assign the ID to a player
#each player will only be sent their task IDs and the info related to their task IDs

enum task_type {BINARY, WIN, ITEM_OUTPUT, ITEM_INPUT, ITEM_INPUT_OUTPUT, MAP_OUTPUT}

enum task_state {NOT_STARTED, IN_PROGRESS, COMPLETED}

var task_transitions: Dictionary = {task_type.BINARY: {task_state.NOT_STARTED: [task_state.COMPLETED], 
														task_state.COMPLETED: []}
									}

#stores info of each task, for instance it's type (see task_type)
var tasks: Dictionary = {"clockset": {"type": task_type.BINARY}}
#array with all names of tasks that can be assigned, most likely used for map specific tasks
var enabled_tasks: Array = ["clockset"]
#dictionary that stores the task IDs corresponding to the tasks assigned to the player
var player_tasks: Dictionary = {}
#stores task info corresponding to task IDs
#format: {<task id>: {name: <task_name>, type: <task type>, state: <task state>, player: <network ID of player task is assigned to>}
var task_dict: Dictionary = {}

func _ready():
	randomize()
	print(gen_unique_id())

#can't declare new_state as an int, otherwise it would need to default to an int which could cause later problems
func advance_task(task_id: int, new_state = null) -> bool:
	if not get_tree().is_network_server():
		return false
	var task_type: int = task_dict[task_id].type
	var current_state: int = task_dict[task_id].state

	#transition if allowed
	if task_transitions[task_type][current_state].empty():
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
	var task_type: int = task_dict[task_id].type
	var current_state: int = task_dict[task_id].state
	#if that task type can't transition from current state to new state
	if not task_transitions[task_type][current_state].has(new_state):
		return false
	#transition task
	task_dict[task_id].state = new_state
	return false

func register_task(player_id: int, task_name: String) -> void:
	var new_task_id: int = gen_unique_id()
	var new_task_dict: Dictionary = {"name": task_name, "type": tasks[task_name].type, "state": task_state.NOT_STARTED, "player": player_id}
	task_dict[new_task_id] = new_task_dict
	assign_task(player_id, new_task_id)

func assign_task(player_id: int, task_id: int) -> void:
	if not player_tasks.keys().has(player_id):
		player_tasks[player_id] = []
	player_tasks[player_id].append(task_id)

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
