extends Control

const NAME_LABEL_KEY = "player_name_label"
var expanded = true
var rightAnchor: float

var tasks: Dictionary = {}
var tree: Tree = null
# for now only the server can display other people's tasks
# was usefull for debuggng. If you want to make this into a feature
# I advise moving this variable to TaskManager autoload, while making sure that
# all of the tasks are acctually sent over to all of the clients 
export var display_other_player_tasks := true

func _ready():
	rightAnchor = get_anchor(MARGIN_RIGHT)
	#warning-ignore:return_value_discarded
	TaskManager.connect("task_completed", self, "_on_task_completed")
	
	# When new roles are assigned, tasks are assigned too
	#warning-ignore:return_value_discarded
	PlayerManager.connect("roles_assigned", self, "_new_tasks_ready")
	
func _on_task_completed(task_info: Dictionary):
	if not TaskManager.is_task_info_valid(task_info):
		return
	var playerID = task_info[TaskManager.PLAYER_ID_KEY]
	
	if not tasks.has(playerID):
		assert(false)
		return
		
	var allTasksCompleted = true
	
	for taskID in TaskManager.player_tasks[playerID]:
		if not tasks[playerID].has(taskID):
			assert(false)
			continue

		var t_info = {	TaskManager.PLAYER_ID_KEY: playerID,
						TaskManager.TASK_ID_KEY: taskID}
		
		if TaskManager.is_task_completed(t_info):
			tasks[playerID][taskID].set_custom_color(0, Color(0.2, 1.0, 0.2))
		else:
			allTasksCompleted = false

	if allTasksCompleted:
		if not tasks[playerID].has(NAME_LABEL_KEY):
			assert(false)
			return
		tasks[playerID][NAME_LABEL_KEY].set_custom_color(0, Color(0.2, 1.0, 0.2))
		tasks[playerID][NAME_LABEL_KEY].set_collapsed(true)

func createTextNode(rootTree: Tree, text: String, root: Object = null) -> TreeItem:
	var node: TreeItem = rootTree.create_item(root)
	node.set_selectable(0, false)
	node.set_cell_mode(0, TreeItem.CELL_MODE_STRING)
	node.set_text(0, text)
	return node
	
func _new_tasks_ready(_playerRoles):
	tasks.clear()
	if tree != null:
		tree.queue_free()
		tree = null
	tree = Tree.new()
	tree.set_anchor(MARGIN_RIGHT, 1.0)
	tree.set_anchor(MARGIN_BOTTOM, 1.0)
	tree.set_hide_root(true)
	var treeRoot = createTextNode(tree, "Tasks")

	populate_tree(treeRoot, TaskManager.GLOBAL_TASK_PLAYER_ID)
	
	var players = Network.get_peers()
	for player in players:
		if not display_other_player_tasks and player != Network.get_my_id():
			continue
		populate_tree(treeRoot, player)
		
	self.add_child(tree)

func populate_tree(treeRoot: TreeItem, player: int):
	if not player in TaskManager.player_tasks:
		return
	if not tasks.has(player):
			tasks[player] = {}
	# The local player should see their tasks listed under "personal tasks" group
	var playerName = "Personal Tasks"
	# Or if the task is global, it should be listed under "Global Tasks" group
	if player == TaskManager.GLOBAL_TASK_PLAYER_ID:
		playerName = "Global Tasks"
	# Or, if these tasks belong to some other player, list them under
	# the group named by their name 
	elif player != Network.get_my_id():
		playerName = Network.get_player_name(player)
	var nl = createTextNode(tree, playerName, treeRoot)
	tasks[player][NAME_LABEL_KEY] = nl
	for taskID in TaskManager.player_tasks[player]:
		var taskInfo = {TaskManager.TASK_ID_KEY: taskID, 
						TaskManager.PLAYER_ID_KEY: Network.get_my_id()}
		var taskName = TaskManager.get_task_data(taskInfo)["task_text"]
		var l = createTextNode(tree, taskName, nl)
		tasks[player][taskID] = l

func _on_Button_pressed():
	if expanded:
		self.set_anchor(MARGIN_RIGHT, 0, true)
	else:
		self.set_anchor(MARGIN_RIGHT, rightAnchor, true)
	expanded = not expanded
