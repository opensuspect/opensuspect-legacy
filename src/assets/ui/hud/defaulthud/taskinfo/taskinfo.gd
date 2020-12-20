extends Control

var expanded = true
var rightAnchor: float

var tasks: Dictionary = {}
var tree: Tree = null
export var display_other_player_tasks := true

func _ready():
	rightAnchor = get_anchor(MARGIN_RIGHT)
	#warning-ignore:return_value_discarded
	TaskManager.connect("task_completed", self, "_on_task_completed")
	
	# When new roles are assigned, we know that the tasks are assigned too
	#warning-ignore:return_value_discarded
	PlayerManager.connect("roles_assigned", self, "_new_tasks_ready")
	
func _on_task_completed(_taskID, playerID):
	if not display_other_player_tasks and Network.get_my_id() != playerID:
		return
	var allTasksCompleted = true
	for taskID in TaskManager.player_tasks[playerID]:
		if TaskManager.is_task_completed(taskID, playerID):
			tasks[playerID][taskID].set_custom_color(0, Color(0.2, 1.0, 0.2))
		elif not TaskManager.is_task_global(taskID):
			allTasksCompleted = false
	if allTasksCompleted:
		tasks[playerID]["player_name_label"].set_custom_color(0, Color(0.2, 1.0, 0.2))
		# if we are showing other people's tasks, collapse to save space
		# otherwise, leave open
		tasks[playerID]["player_name_label"].set_collapsed(display_other_player_tasks)

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
	var treeRoot = null
	if display_other_player_tasks:
		treeRoot = createTextNode(tree, "Tasks")

	populate_tree(treeRoot, TaskManager.GLOBAL_TASK_ID)
	
	var players = Network.get_peers()
	for player in players:
		if not display_other_player_tasks and Network.get_my_id() != player:
			continue
		populate_tree(treeRoot, player)
		
	self.add_child(tree)

func populate_tree(treeRoot: TreeItem, player: int):
	if not player in TaskManager.player_tasks:
		return
	if not tasks.has(player):
			tasks[player] = {}
	var playerName = Network.get_player_name(player)
	if player == TaskManager.GLOBAL_TASK_ID:
		playerName = "Global Tasks"
	var nl = createTextNode(tree, playerName, treeRoot)
	tasks[player]["player_name_label"] = nl
	for taskID in TaskManager.player_tasks[player]:
		var taskName = TaskManager.get_task_data(taskID)["task_text"]
		var l = createTextNode(tree, taskName, nl)
		tasks[player][taskID] = l

func _on_Button_pressed():
	if expanded:
		self.set_anchor(MARGIN_RIGHT, 0, true)
	else:
		self.set_anchor(MARGIN_RIGHT, rightAnchor, true)
	expanded = not expanded
