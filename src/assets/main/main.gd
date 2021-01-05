extends Node2D

export (int) var MAX_PLAYERS = 10
#!!!THIS IS IMPORTANT!!!
#CHANGE THIS VARIABLE BY ONE EVERY COMMIT TO PREVENT OLD CLIENTS FROM TRYING TO CONNECT TO SERVERS!!!
#A way to make up version number: year month date hour of editing this script
var version = 210108
var intruders = 0
var newnumber
var player_spawn_points: Dictionary

func _ready() -> void:
	set_network_master(1)
	GameManager.connect("state_changed_priority", self, "state_changed_priority")

# Gets called when the title scene sets this scene as the main scene
func _enter_tree() -> void:
	# The appearance customization of current player gets copied to the appearance list
	AppearanceManager.enableMyAppearance()
	if Network.connection == Network.Connection.CLIENT_SERVER:
# warning-ignore:return_value_discarded
		get_tree().connect("network_peer_disconnected", self, "_player_disconnected")
# warning-ignore:return_value_discarded
		Network.connect("connection_handled", self, "connection_handled")
		PlayerManager.ournumber = 0
		$players.createPlayer(Network.get_my_id(), Network.get_player_name())
	elif Network.connection == Network.Connection.CLIENT:
# warning-ignore:return_value_discarded
		get_tree().connect("network_peer_disconnected", self, "_player_disconnected")

func main_player_id():
	"""Returns the id of the main player (the player who is the playable character
	on this instance)"""
	for player_id in $players.players.keys():
		if $players.players[player_id].main_player:
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
	for i in $players.players.keys():
		if i != id:
			print("telling ", i, " to create player ", id)
			#tell players to crate new player; running from $players because that's where the function is. rpc is wack man.
			$players.rpc_id(i, "createPlayer", id, playerName, $players.spawn_pos)
	#tell new player to create existing players
	print("telling ", id, " to create players")
	$players.rpc_id(id, "createPlayers", Network.get_player_names())

puppet func checkVersion(sversion: int) -> void:
	if version != sversion:
		print("HEY! YOU! YOU FORGOT TO UPDATE YOUR CLIENT. RE EXPORT AND TRY AGAIN!")

puppet func receiveNumber(number: int) -> void:
	if get_tree().get_rpc_sender_id() != 1:
		return
	PlayerManager.ournumber = number

func _player_disconnected(id):
	$players.players[id].queue_free() #deletes player node when a player disconnects
	$players.players.erase(id)
	PlayerManager.players.erase(id)

master func _on_maps_spawn(spawnPositions: Array):
	if not get_tree().is_network_server():
		return
	$players.spawn_pos = spawnPositions[0]
	#generate spawn point dict
	var spawnPointDict: Dictionary = {}
	for i in $players.players.keys().size():
		spawnPointDict[$players.players.keys()[i]] = spawnPositions[i % spawnPositions.size()]
		if spawnPointDict[$players.players.keys()[i]] == null:
			spawnPointDict[$players.players.keys()[i]] = $players.spawn_pos
	player_spawn_points = spawnPointDict
	#spawn players
	#rpc("createPlayers", Network.get_player_names(), spawnPointDict)

func state_changed_priority(old_state: int, new_state, priority: int):
	if priority != 5:
		return
	if new_state == GameManager.State.Lobby or new_state == GameManager.State.Normal:
		$players.rpc("createPlayers", Network.get_player_names(), player_spawn_points)
