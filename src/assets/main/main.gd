extends Node2D

export (int) var MAX_PLAYERS = 10
#!!!THIS IS IMPORTANT!!!
#CHANGE THIS VARIABLE BY ONE EVERY COMMIT TO PREVENT OLD CLIENTS FROM TRYING TO CONNECT TO SERVERS!!!
#A way to make up version number: year month date hour of editing this script
var version = 21011014
var intruders = 0 # NiceMicro's question: is this value ever referenced anywhere?
var newnumber
var player_spawn_points: Dictionary

func _ready() -> void:
	set_network_master(1)

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
	$players.tell_all_to_setup_new_player(id, playerName)

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

func _on_main_player_picked_up_item(item_path: String) -> void:
	"""Runs when the main player sends a request to pick up an item."""
	rpc_id(1, "player_picked_up_item", item_path)

func _on_main_player_dropped_item() -> void:
	"""Runs when the main player sends a request to drop an item."""
	rpc_id(1, "player_dropped_item")

remotesync func player_picked_up_item(item_path: String) -> void:
	"""Runs on the server; RPCs all clients to have a player pick up an item."""
	if not get_tree().is_network_server():
		return
	var id: int = get_tree().get_rpc_sender_id()
	if not $players.players.keys().has(id):
		return
	rpc("pick_up_item", id, item_path)

remotesync func player_dropped_item() -> void:
	"""Runs on the server; RPCs all clients to have a player drop an item."""
	if not get_tree().is_network_server():
		return
	var id: int = get_tree().get_rpc_sender_id()
	if not $players.players.keys().has(id):
		return
	rpc("drop_item", id)

puppetsync func pick_up_item(id: int, item_path: String) -> void:
	"""Actually have a player pick up an item."""
	var player_item_handler: ItemHandler = $players.players[id].item_handler
	var found_item: Item = get_tree().get_root().get_node(item_path)
	player_item_handler.pick_up(found_item)

puppetsync func drop_item(id: int) -> void:
	"""Actually have a player drop an item."""
	var player_item_handler: ItemHandler = $players.players[id].item_handler
	var item: Item = player_item_handler.picked_up_item
	player_item_handler.drop(item)

master func _on_maps_spawn(spawnPositions: Array):
	if not get_tree().is_network_server():
		return
	$players.spawn_pos = spawnPositions[0]
	#generate spawn point dict
	var spawnPointDict: Dictionary = {}
# <<<<<<< HEAD (from Jngo's PR with the items and inventory)
#	for i in players.keys().size():
#		spawnPointDict[players.keys()[i]] = spawnPositions[i % spawnPositions.size()]
#		if spawnPointDict[players.keys()[i]] == null:
#			spawnPointDict[players.keys()[i]] = spawn_pos
#	#spawn players
#	rpc("createPlayers", Network.get_player_names(), spawnPointDict)
# =======
	for i in $players.players.keys().size():
		spawnPointDict[$players.players.keys()[i]] = spawnPositions[i % spawnPositions.size()]
		if spawnPointDict[$players.players.keys()[i]] == null:
			spawnPointDict[$players.players.keys()[i]] = $players.spawn_pos
	player_spawn_points = spawnPointDict
# >>>>>>> main
