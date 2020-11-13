extends Node

#The task manager is going to assign each task a unique ID, and then assign the ID to a player
#each player will only be sent their task IDs and the info related to their task IDs

enum task_type {BINARY, WIN, ITEM_OUTPUT, ITEM_INPUT, MAP_OUTPUT}

#stores info of each task, for instance it's type (see task_type)
var tasks: Dictionary = {"clockset": {"type": task_type.BINARY}}
#array with all names of tasks that can be assigned, most likely used for map specific tasks
var enabled_tasks: Array = ["clockset"]
#dictionary that stores the task IDs corresponding to the tasks assigned to the player
var player_tasks: Dictionary = {}
#stores task info corresponding to task IDs
var task_dict: Dictionary = {}

func _ready():
	randomize()
	print(gen_unique_id())

func register_task():
	pass

func assign_task(player_id: int, task_id: int):
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
