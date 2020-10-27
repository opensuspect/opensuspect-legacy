extends Node2D

export (int) var MAX_PLAYERS = 10
export (String, FILE, "*.tscn") var player_s = "res://assets/player/player.tscn"
var player_scene = load(player_s)
#onready var player_scene = preload(player_s)
# Used on both sides, to keep track of all players.
var players = {}
#!!!THIS IS IMPORTANT!!!
#INCREASE THIS VARIABLE BY ONE EVERY COMMIT TO PREVENT OLD CLIENTS FROM TRYING TO CONNECT TO SERVERS!!!
var version = 5
var intruders = 0
var newnumber
onready var config = ConfigFile.new()

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
		players[1] = $players/Player
		PlayerManager.ournumber = 0
	elif Network.connection == Network.Connection.CLIENT:
		get_tree().connect("network_peer_disconnected", self, "_player_disconnected")
		#print("Connecting to ", Network.host, " on port ", Network.port)
		#var peer = NetworkedMultiplayerENet.new()
		#peer.create_client(Network.host, Network.port)
		#get_tree().network_peer = peer

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

# Called from client sides when a player moves
remote func player_moved(new_pos, new_movement):
	# Should only be run on the server
	if !get_tree().is_network_server():
		return
	var id = get_tree().get_rpc_sender_id()
	#print(id)
	#print("Got player move from ", id) #no reason to spam console so much
	# Check movement validity here
	if not players.keys().has(id):
		return
	players[id].move_to(new_pos, new_movement)
	# The move_to function validates new_x, new_y,
	# so that's why we don't reuse them
	new_pos = players[id].position
	for other_id in players:
		if id != other_id && other_id != 1:
			#print("Sending player moved to client ", other_id) #no reason to spam console so much
			rpc_id(other_id, "other_player_moved", id, new_pos, new_movement)

# Called from server when other players move
puppet func other_player_moved(id, new_pos, new_movement):
	#print("Moving ", id, " to ", new_pos.x, ", ", new_pos.y) #no reason to spam console so much
	if players.keys().has(id):
		players[id].move_to(new_pos, new_movement)

func _on_main_player_moved(position : Vector2, movement : Vector2):
	#In the beginning Godot created the heaven and the earth
	#about 100% of the fix for the "host invisible" bug
	if not get_tree().is_network_server():
		rpc_id(1, "player_moved", position, movement)
	else:
		rpc("other_player_moved", 1, position, movement)
