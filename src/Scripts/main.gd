extends Node2D

export (int) var SERVER_PORT = 1234
export (int) var MAX_PLAYERS = 10

var player_scene = preload("res://Scenes/player.tscn")
# Used on both sides, to keep track of all players.
var players = {}

func _ready():
	$Player.connect("main_player_moved", self, "_on_main_player_moved")

# Gets called when the title scene sets this scene as the main scene
func _enter_tree():
	if "--server" in OS.get_cmdline_args():
		print("Starting server")
		var peer = NetworkedMultiplayerENet.new()
		peer.create_server(SERVER_PORT, MAX_PLAYERS)
		get_tree().network_peer = peer
		get_tree().connect("network_peer_connected", self, "_player_connected")
	else:
		print("Connecting to localhost:", SERVER_PORT)
		var peer = NetworkedMultiplayerENet.new()
		peer.create_client("localhost", SERVER_PORT)
		get_tree().network_peer = peer

# Called on the server when a new client connects
func _player_connected(id):
	var new_player = player_scene.instance()
	new_player.id = id
	new_player.main_player = false
	for id in players:
		# Sends an add_player rpc to the player that just joined
		print("Sending add player to new player ", new_player)
		rpc_id(new_player.id, "player_join", id)
		# Sends the add_player rpc to all other clients
		print("Sending add player to other player ", players[id])
		rpc_id(id, "player_join", new_player.id)

	players[id] = new_player
	add_child(new_player)
	print("Got connection: ", id)
	print("Players: ", players)

# Called from server when another client connects
remote func player_join(other_id):
	# Should only be run on the client
	if get_tree().is_network_server():
		return
	var new_player = player_scene.instance()
	new_player.id = other_id
	new_player.main_player = false
	add_child(new_player)
	players[other_id] = new_player
	print("New player: ", other_id)

# Called from client sides when a player moves
remote func player_moved(new_x, new_y):
	# Should only be run on the server
	if !get_tree().is_network_server():
		return
	var id = get_tree().get_rpc_sender_id()
	print("Got player move from ", id)
	# Check movement validity here
	players[id].move_to(new_x, new_y)
	# The move_to function validates new_x, new_y,
	# so that's why we don't reuse them
	var new_pos = players[id].position
	for other_id in players:
		if id != other_id:
			print("Sending player moved to client ", other_id)
			rpc_id(other_id, "other_player_moved", id, new_pos.x, new_pos.y)

# Called from server when other players move
remote func other_player_moved(id, new_x, new_y):
	# Should only be run on the client
	if get_tree().is_network_server():
		return
	print("Moving ", id, " to ", new_x, ", ", new_y)
	players[id].move_to(new_x, new_y)

func _on_main_player_moved(position : Vector2):
	rpc_id(1, "player_moved", position.x, position.y)
