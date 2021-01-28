extends YSort
signal positions_updated(last_received_input)
export (String, FILE, "*.tscn") var player_s = "res://assets/player/player.tscn"
# Used on both sides, to keep track of all players.
var players = {}
var player_scene = load(player_s)
#onready var player_scene = preload(player_s)
#idNameDict should look like {<network ID>: <player name>}
var spawn_pos = Vector2(0,0)

func _ready():
	GameManager.connect("state_changed_priority", self, "state_changed_priority")

func tell_all_to_setup_new_player(id, playerName):
	#tell all existing players to create this player
	for i in players.keys():
		if i != id:
			print("telling ", i, " to create player ", id)
			#tell players to create new player; running from $players because that's where the function is. rpc is wack man.
			rpc_id(i, "createPlayer", id, playerName, spawn_pos)
	#tell new player to create existing players
	print("telling ", id, " to create players")
	rpc_id(id, "createPlayers", Network.get_player_names())

puppetsync func createPlayers(idNameDict: Dictionary, spawnPointDict: Dictionary = {}) -> void:
	deletePlayers()
	for i in idNameDict.keys():
		if spawnPointDict.keys().has(i):
			#spawn at spawn point
			createPlayer(i, idNameDict[i], spawnPointDict[i])
		else:
			createPlayer(i, idNameDict[i], spawn_pos)
	# Assign Main's players to the PlayerManager singleton so they may be accessed anywhere
	PlayerManager.players = players

puppetsync func createPlayer(id: int, playerName: String, spawnPoint: Vector2 = Vector2(0,0)) -> void:
	print("(players.gd/createPlayer) creating player ", id)
	if players.keys().has(id):
		print("not creating player, already exists")
		return
	var newPlayer = player_scene.instance()
	newPlayer.id = id
	newPlayer.setName(playerName)
	#newPlayer.set_network_master(id)
	if id == Network.get_my_id():
		newPlayer.main_player = true
		newPlayer.connect("main_player_moved", self, "_on_main_player_moved")
		self.connect("positions_updated", newPlayer, "_on_positions_updated")
		var player_item_handler: ItemHandler = newPlayer.get_node("ItemHandler")
		player_item_handler.connect("main_player_picked_up_item", self, "_on_main_player_picked_up_item")
		player_item_handler.connect("main_player_dropped_item", self, "_on_main_player_dropped_item")
	players[id] = newPlayer
	add_child(newPlayer)
	newPlayer.move_to(spawnPoint, Vector2(0,0))

func deletePlayers() -> void:
	for i in players.keys():
		players[i].queue_free()
	players.clear()
	PlayerManager.players.clear()


# Called from server when the server's players move
puppet func update_positions(positions_dict: Dictionary, last_received_input: int) -> void:
	for id in positions_dict.keys():
		if players.keys().has(id):
			players[id].move_to(positions_dict[id][0], positions_dict[id][1])
			players[id].velocity = positions_dict[id][2]
	emit_signal("positions_updated", last_received_input)

func _on_main_player_moved(movement: Vector2, velocity: Vector2, last_input: int):
	if not get_tree().is_network_server():
		rpc_id(1, "player_moved", movement, velocity, last_input)

# Keep the clients' player positions updated
func _physics_process(_delta: float) -> void:
	if get_tree().is_network_server():
		var positions_dict = {}
		for id in players.keys():
			positions_dict[id] = [players[id].position, players[id].movement, players[id].velocity]
		for id in players.keys():
			if id != 1:
				rpc_id(id, "update_positions", positions_dict, players[id].input_number)

func get_network_id_from_player_node_name(node_name: String) -> int:
	"""Fetch a player's network ID from the name of their KinematicBody2D."""
	var players_dict: Dictionary = PlayerManager.players
	var players_array: Array = players_dict.values()
	for index in range(len(players_array)):
		if players_array[index].name == node_name:
			return players_dict.keys()[index]
	return -1

# Called from client side to tell the server about the player's actions
remote func player_moved(new_movement: Vector2, velocity: Vector2, last_input: int) -> void:
	# Should only be run on the server
	if !get_tree().is_network_server():
		return
	var id = get_tree().get_rpc_sender_id()
	if not players.keys().has(id):
		return
	# Check movement validity
	if new_movement.length() > 1:
		new_movement = new_movement.normalized()
	players[id].movement = new_movement
	players[id].input_number = last_input


func _on_infiltrator_kill(killer: KinematicBody2D, killed_player: KinematicBody2D) -> void:
	"""
	Runs on the infiltrator's Main scene; sends an RPC to the server to indicate
	that the infiltrator has killed a player, and also sends an RPC to the server
	to initiate a check whether the win conditions have been achieved.
	"""
	var killer_id: int = get_network_id_from_player_node_name(killer.name)
	var killed_player_id: int = get_network_id_from_player_node_name(killed_player.name)
	
	if not players.keys().has(killer_id) or not players.keys().has(killed_player_id):
		return
	if get_tree().is_network_server():
		# Killer is the network server
		infiltrator_killed_player(killer_id, killed_player_id)
		#check if a round ends due to passing winning conditions:
		get_parent().get_node("winlosscontroller").victory_check() 
	else:
		rpc_id(1, "infiltrator_killed_player", killer_id, killed_player_id)
		#ask the server to check if a round ends due to passing winning conditions:
		get_parent().get_node("winlosscontroller").rpc_id(1, "victory_check")
		# ^^ we're running the rpc from winlosscontroller because that's where the function is
remote func infiltrator_killed_player(killer_id: int, killed_player_id: int) -> void:
	"""
	Runs on the server; sends an RPC to every player to indicate that a
	particular player has been killed.
	"""
	if not get_tree().is_network_server():
		return

	for player_id in players.keys():
		rpc_id(player_id, "player_killed", killer_id, killed_player_id)

puppetsync func player_killed(killer_id: int, killed_player_id: int) -> void:
	"""Runs on a client; responsible for actually killing off a player."""
	var killed_player_death_handler: Node2D = players[killed_player_id].get_node("DeathHandler")
	killed_player_death_handler.die_by(killer_id)

func state_changed_priority(old_state: int, new_state, priority: int):
	if priority != 5:
		return
	print("(players.gd/state_changed_priority)")
	if new_state == GameManager.State.Lobby or new_state == GameManager.State.Normal:
		rpc("createPlayers", Network.get_player_names(), get_parent().player_spawn_points)


#---------------------------------------------------------------
# Items related stuff, maybe should have their own script?
#---------------------------------------------------------------

func _on_main_player_picked_up_item(item_path: String) -> void:
	"""Runs when the main player sends a request to pick up an item."""
	# print("(players.gd/_on_main_player_picked_up_item) ", item_path)
	rpc_id(1, "player_picked_up_item", item_path)

func _on_main_player_dropped_item() -> void:
	"""Runs when the main player sends a request to drop an item."""
	# print("(players.gd/_on_main_player_dropped_item)")
	rpc_id(1, "player_dropped_item")

remotesync func player_picked_up_item(item_path: String) -> void:
	"""Runs on the server; RPCs all clients to have a player pick up an item."""
	if not get_tree().is_network_server():
		return
	var id: int = get_tree().get_rpc_sender_id()
	if not players.keys().has(id):
		return
	# print("(players.gd/player_picked_up_item) player=", id, " item=", item_path)
	rpc("pick_up_item", id, item_path)

remotesync func player_dropped_item() -> void:
	"""Runs on the server; RPCs all clients to have a player drop an item."""
	if not get_tree().is_network_server():
		return
	var id: int = get_tree().get_rpc_sender_id()
	if not players.keys().has(id):
		return
	# print("(players.gd/player_dropped_item) player=", id)
	rpc("drop_item", id)

puppetsync func pick_up_item(id: int, item_path: String) -> void:
	"""Actually have a player pick up an item."""
	var player_item_handler: ItemHandler = players[id].item_handler
	var found_item: Item = get_tree().get_root().get_node(item_path)
	# print("(players.gd/player_picked_up_item) player=", id, " item=", item_path)
	player_item_handler.pick_up(found_item)

puppetsync func drop_item(id: int) -> void:
	"""Actually have a player drop an item."""
	var player_item_handler: ItemHandler = players[id].item_handler
	var item: Item = player_item_handler.picked_up_item
	# print("(players.gd/player_dropped_item) player=", id)
	player_item_handler.drop(item)
