extends Node2D

export (int) var SERVER_PORT = 1234
export (int) var MAX_PLAYERS = 10
export (NodePath) var player_path
onready var player_node = get_node(player_path)

var players = {}

func _ready():
	if "--server" in OS.get_cmdline_args():
		var peer = NetworkedMultiplayerENet.new()
		peer.create_server(SERVER_PORT, MAX_PLAYERS)
		get_tree().network_peer = peer
		get_tree().connect("network_peer_connected", self, "_player_connected")
		print("Starting server")
	else:
		var peer = NetworkedMultiplayerENet.new()
		peer.create_client("localhost", SERVER_PORT)
		get_tree().network_peer = peer
		get_tree().connect("add_player", self, "_player_joined")

# Called on the server when a new client connects
func _player_connected(id):
	var new_player = player_node.duplicate()
	new_player.id = id
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

# Called on the client when another client connects
remote func player_join(other_id):
	var new_player = player_node.duplicate()
	new_player.id = other_id
	add_child(new_player)
	print("New player: ", other_id)
