extends Node2D

export (int) var SERVER_PORT = 1234
export (int) var MAX_PLAYERS = 10

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

func _player_connected(id):
	print("Got connectio: ", id)
