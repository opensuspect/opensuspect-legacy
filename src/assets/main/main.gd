extends Node2D

export (int) var MAX_PLAYERS = 10
export (String, FILE, "*.tscn") var player_s = "res://assets/player/player.tscn"
var player_scene = load(player_s)
#onready var player_scene = preload(player_s)
# Used on both sides, to keep track of all players.
var players = {}
#!!!THIS IS IMPORTANT!!!
#CHANGE THIS VARIABLE BY ONE EVERY COMMIT TO PREVENT OLD CLIENTS FROM TRYING TO CONNECT TO SERVERS!!!
#A way to make up version number: year month date hour of editing this script
var version = 20122016
var intruders = 0
var newnumber
var spawn_pos = Vector2(0,0)
var player_spawn_points: Dictionary

signal positions_updated(last_received_input)

func _ready() -> void:
	set_network_master(1)
	GameManager.connect("state_changed_priority", self, "state_changed_priority")

# Gets called when the title scene sets this scene as the main scene
func _enter_tree() -> void:
	if Network.connection == Network.Connection.CLIENT_SERVER:
# warning-ignore:return_value_discarded
		get_tree().connect("network_peer_disconnected", self, "_player_disconnected")
# warning-ignore:return_value_discarded
		Network.connect("connection_handled", self, "connection_handled")
		PlayerManager.ournumber = 0
		createPlayer(Network.get_my_id(), Network.get_player_name())
	elif Network.connection == Network.Connection.CLIENT:
# warning-ignore:return_value_discarded
		get_tree().connect("network_peer_disconnected", self, "_player_disconnected")

# Keep the clients' player positions updated
func _physics_process(_delta: float) -> void:
	if get_tree().is_network_server():
		var positions_dict = {}
		for id in players.keys():
			positions_dict[id] = [players[id].position, players[id].movement, players[id].velocity]
		for id in players.keys():
			if id != 1:
				rpc_id(id, "update_positions", positions_dict, players[id].input_number)

func main_player_id():
	"""Returns the id of the main player (the player who is the playable character
	on this instance)"""
	for player_id in players.keys():
		if players[player_id].main_player:
			return player_id
	return -1

func connection_handled(id: int, playerName: String) -> void:
	print("connection handled, id: ", id, " name: ", playerName)
	if not get_tree().is_network_server():
		return
	rpc("checkVersion", version)
	newnumber = Network.peers.size()
	rpc_id(id, "receiveNumber", newnumber)
	#tell all existing players to create this player
	for i in players.keys():
		if i != id:
			print("telling ", i, " to create player ", id)
			rpc_id(i, "createPlayer", id, playerName, spawn_pos)
	#tell new player to create existing players
	print("telling ", id, " to create players")
	rpc_id(id, "createPlayers", Network.get_player_names())

puppet func checkVersion(sversion: int) -> void:
	if version != sversion:
		print("HEY! YOU! YOU FORGOT TO UPDATE YOUR CLIENT. RE EXPORT AND TRY AGAIN!")

puppet func receiveNumber(number: int) -> void:
	if get_tree().get_rpc_sender_id() != 1:
		return
	PlayerManager.ournumber = number

func _player_disconnected(id):
	players[id].queue_free() #deletes player node when a player disconnects
	players.erase(id)
	PlayerManager.players.erase(id)

#idNameDict should look like {<network ID>: <player name>}
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
	print("creating player ", id)
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
	newPlayer.customizePlayer(AppearanceManager.getPlayerAppearance(id))
	players[id] = newPlayer
	$players.add_child(newPlayer)
	newPlayer.move_to(spawnPoint, Vector2(0,0))

func deletePlayers() -> void:
	for i in players.keys():
		players[i].queue_free()
	players.clear()
	PlayerManager.players.clear()

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

master func _on_maps_spawn(spawnPositions: Array):
	if not get_tree().is_network_server():
		return
	spawn_pos = spawnPositions[0]
	#generate spawn point dict
	var spawnPointDict: Dictionary = {}
	for i in players.keys().size():
		spawnPointDict[players.keys()[i]] = spawnPositions[i % spawnPositions.size()]
		if spawnPointDict[players.keys()[i]] == null:
			spawnPointDict[players.keys()[i]] = spawn_pos
	player_spawn_points = spawnPointDict
	#spawn players
	#rpc("createPlayers", Network.get_player_names(), spawnPointDict)

func state_changed_priority(old_state: int, new_state, priority: int):
	if priority != 5:
		return
	if new_state == GameManager.State.Lobby or new_state == GameManager.State.Normal:
		rpc("createPlayers", Network.get_player_names(), player_spawn_points)

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
		victory_check()
	else:
		rpc_id(1, "infiltrator_killed_player", killer_id, killed_player_id)
		#ask the server to check if a round ends due to passing winning conditions:
		rpc_id(1, "victory_check")

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

puppetsync func end_round(winner):
	"""This function is called by the server and when it is, it would need to
	show the win / lose screens for the players, and then transitions back
	to the lobby."""
	var main_player
	main_player = main_player_id()
	if main_player == -1:
		#TODO
		#Here should be the code for whatever happens on a dedicated server at the
		#end of the turn
		pass
	elif PlayerManager.get_player_team(main_player):
		#TODO
		#Here should be the code for displaying the victory screen
		pass
	else:
		#TODO
		#Here should be the code for displaying the defeat screen
		pass
	GameManager.transition(GameManager.State.Lobby)

master func victory_check():
	"""Checks all possible victory conditions, and if any passes, tells all clients
	to proceed to the victory / defeat screens"""
	var victorious: int
	
	victorious = -1
	#TODO:
	#Here, there should be a check whether the current map allows for elimination victory ot not
	if victorious == -1:
		victorious = elimination_victory_check(0)
	#TODO
	#Here, all other victory conditions should be checked.
	if victorious != -1:
		for player_id in players.keys():
			rpc_id(player_id, "end_round", victorious)

func elimination_victory_check(main_team: int):
	"""Checks whether the elimination victory has been achieved. Returns -1
	if no one wins, otherwise returns the number of the winning tean
	main_team: this variable is the team number of the team that needs to keep
		hold of the majority of the players, and they only win if every other team
		got eliminated."""
	var players_left = {}
	var players_team: int
	var enabled_teams
	var total_players = 0
	var max_member = -1
	var max_team = -1
	
	#Counting up the alive members of each teams
	enabled_teams = PlayerManager.get_enabledTeams()
	for team in enabled_teams:
		players_left[team] = 0
	for player in PlayerManager.players.keys():
		if PlayerManager.players[player].get_is_alive():
			players_team = PlayerManager.get_player_team(player)
			players_left[players_team] = players_left[players_team] + 1
	
	#Looks for the team with the largest number of players except the main team
	#In case of a tie in terms of player numbers, the lower team number will
	#be handled as the majority: if everyone of the main team is dead, and two-two
	#players are left alive from teams 1 and 2, team 1 wins
	for team in enabled_teams:
		total_players = total_players + players_left[team]
		if players_left[team] > max_member and team != main_team:
			max_member = players_left[team]
			max_team = team
	
	if total_players == players_left[main_team]:
		#All players who are left are from the main team, no infiltrators remain
		return main_team
	elif max_member >= total_players-max_member:
		#Any infiltrator team that managed to get at least 50% of alive players, wins
		return max_team
	
	return -1

func get_network_id_from_player_node_name(node_name: String) -> int:
	"""Fetch a player's network ID from the name of their KinematicBody2D."""
	var players_dict: Dictionary = PlayerManager.players
	var players_array: Array = players_dict.values()
	for index in range(len(players_array)):
		if players_array[index].name == node_name:
			return players_dict.keys()[index]
	return -1
