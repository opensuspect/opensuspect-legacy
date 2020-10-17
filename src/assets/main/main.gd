extends Node2D

export (int) var MAX_PLAYERS = 10
export (String, FILE, "*.tscn") var player_s = "res://assets/player/player.tscn"
var player_scene = load(player_s)
#onready var player_scene = preload(player_s)
# Used on both sides, to keep track of all players.
var players = {}

onready var config = ConfigFile.new()

func _ready():
	var err = config.load("user://settings.cfg")
	if err == OK:
		$players/Player/Camera2D/CanvasLayer/ColorRect.material.set_shader_param("mode", int(config.get_value("general", "colorblind_mode")))
	

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
	elif Network.connection == Network.Connection.CLIENT:
		get_tree().connect("network_peer_disconnected", self, "_player_disconnected")
		player_join(1,"PLACEHOLDER NAME, THIS IS THE HOST")
		#print("Connecting to ", Network.host, " on port ", Network.port)
		#var peer = NetworkedMultiplayerENet.new()
		#peer.create_client(Network.host, Network.port)
		#get_tree().network_peer = peer

# Called on the server when a new client connects
func _player_connected(id):
	rpc_id(id,"getname",id)

remote func getname(id):
	rpc_id(1,"playerjoin_proper",Network.playername,id)
remote func playerjoin_proper(thename,id):
	var new_player = player_scene.instance()
	id = get_tree().get_rpc_sender_id()
	new_player.id = id
	new_player.ourname = thename
	new_player.main_player = false
	print(thename)
	for id in players:
		# Sends an add_player rpc to the player that just joined
		print("Sending add player to new player ", new_player)
		rpc_id(new_player.id, "player_join", id, thename)
		# Sends the add_player rpc to all other clients
		print("Sending add player to other player ", players[id])
		rpc_id(id, "player_join", new_player.id, thename)
	players[id] = new_player
	$players.add_child(new_player)
	print("Got connection: ", id)
	print("Players: ", players)
func _player_disconnected(id):
	players[id].queue_free() #deletes player node when a player disconnects
	players.erase(id)

# Called from server when another client connects
remote func player_join(other_id, pname):
	# Should only be run on the client
	if get_tree().is_network_server():
		return
	var new_player = player_scene.instance()
	new_player.id = other_id
	new_player.ourname = pname
	new_player.main_player = false
	add_child(new_player)
	players[other_id] = new_player
	print("New player: ", other_id)

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
remote func other_player_moved(id, new_pos, new_movement):
	# Should only be run on the client
	if get_tree().is_network_server():
		return
	#print("Moving ", id, " to ", new_pos.x, ", ", new_pos.y) #no reason to spam console so much
	players[id].move_to(new_pos, new_movement)

func _on_main_player_moved(position : Vector2, movement : Vector2):
	#In the beginning Godot created the heaven and the earth
	#about 100% of the fix for the "host invisible" bug
	if not get_tree().is_network_server():
		rpc_id(1, "player_moved", position, movement)
	else:
		rpc("other_player_moved", 1, position, movement)
