extends Node2D

export (int) var MAX_PLAYERS = 10
export (String, FILE, "*.tscn") var player_s = "res://assets/player/player.tscn"
var player_scene = load(player_s)
#onready var player_scene = preload(player_s)
# Used on both sides, to keep track of all players.
var players = {}
#!!!THIS IS IMPORTANT!!!
#INCREASE THIS VARIABLE BY ONE EVERY COMMIT TO PREVENT OLD CLIENTS FROM TRYING TO CONNECT TO SERVERS!!!
var version = 9
var intruders = 0
var newnumber
var spawn_pos = Vector2(0,0)
var recentmap = ""
func _ready():
	set_network_master(1)


	$players/Player.connect("main_player_moved", self, "_on_main_player_moved")
# Gets called when the title scene sets this scene as the main scene
func _enter_tree():
	if Network.connection == Network.Connection.CLIENT_SERVER:
		#print("Starting server")
		#var peer = NetworkedMultiplayerENet.new()
		#peer.create_server(Network.port, MAX_PLAYERS)
		#get_tree().network_peer = peer
		get_tree().connect("network_peer_connected", self, "_player_connected")
		get_tree().connect("network_peer_disconnected", self, "_player_disconnected")
		Network.connect("connection_handled", self, "connection_handled")
		PlayerManager.ournumber = 0
	elif Network.connection == Network.Connection.CLIENT:
		get_tree().connect("network_peer_disconnected", self, "_player_disconnected")
		#print("Connecting to ", Network.host, " on port ", Network.port)
		#var peer = NetworkedMultiplayerENet.new()
		#peer.create_client(Network.host, Network.port)
		#get_tree().network_peer = peer
	players[get_tree().get_network_unique_id()] = $players/Player

# Keep the clients' player positions updated
func _physics_process(delta):
	if get_tree().is_network_server():
		var positions_dict = {}
		for id in players.keys():
			positions_dict[id] = [players[id].position, players[id].movement]
		rpc("update_positions", positions_dict)

func connection_handled(id, playerName):
	print("connection handled, id: ", id, " name: ", playerName)
	if not get_tree().is_network_server():
		return
	rpc("checkVersion", version)
	newnumber = Network.peers.size()
	rpc_id(id, "receiveNumber", newnumber)
	createPlayer(id, playerName)
	#tell all existing players to create this player
	for i in players.keys():
		if i != id:
			print("telling ", i, " to create player ", id)
			rpc_id(i, "createPlayer", id, playerName)
	#tell new player to create existing players
	for i in players.keys():
		if i != id:
			print("telling ", id, " to create player ", i)
			rpc_id(id, "createPlayer", i, Network.names[i])

puppet func checkVersion(sversion):
	if version != sversion:
		print("HEY! YOU! YOU FORGOT TO UPDATE YOUR CLIENT. RE EXPORT AND TRY AGAIN!")

puppet func receiveNumber(number):
	if get_tree().get_rpc_sender_id() != 1:
		return
	PlayerManager.ournumber = number

# Called on the server when a new client connects
func _player_connected(id):
	return

func _player_disconnected(id):
	players[id].queue_free() #deletes player node when a player disconnects
	players.erase(id)

puppet func createPlayer(id, playerName):
	print("creating player ", id)
	if players.keys().has(id):
		print("not creating player, already exists")
		return
	var newPlayer = player_scene.instance()
	newPlayer.id = id
	newPlayer.ourname = playerName
	newPlayer.main_player = false
	players[id] = newPlayer
	$players.add_child(newPlayer)
	newPlayer.setName(playerName)
	print("New player: ", id)
	_on_maps_spawn(spawn_pos, recentmap)

# Called from client side to tell the server about the player's actions
remote func player_moved(new_movement):
	# Should only be run on the server
	if !get_tree().is_network_server():
		return
	var id = get_tree().get_rpc_sender_id()
	#print(id)
	#print("Got player move from ", id) #no reason to spam console so much
	if not players.keys().has(id):
		return
	# Check movement validity
	if new_movement.length() > 1:
		new_movement = new_movement.normalized()
	players[id].movement = new_movement

# Called from server when the server's players move
puppet func update_positions(positions_dict):
	for id in positions_dict.keys():
		if players.keys().has(id):
			players[id].move_to(positions_dict[id][0], positions_dict[id][1])

func _on_main_player_moved(movement : Vector2):
	if not get_tree().is_network_server():
		rpc_id(1, "player_moved", movement)


func _on_maps_spawn(position,frommap):
	# move players to spawn point
	spawn_pos = position
	recentmap = frommap
	var arrpos = 0
	for i in players.keys().size():
		if not frommap in players[players.keys()[i]].spawned:
			players[players.keys()[i]].move_to(Vector2(position.x+((arrpos)*80),position.y),5)
			players[players.keys()[i]].spawned.append(frommap)
		arrpos += 1
