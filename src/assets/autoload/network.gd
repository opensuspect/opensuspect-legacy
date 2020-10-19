extends Node
enum Connection {
	LOCAL,				# Local only game, tutorial
	DEDICATED_SERVER,	# Server only, no local client
	CLIENT_SERVER,		# Server with a local player
	CLIENT				# Client only, remote server
}

var connection: int = Connection.LOCAL setget toss, get_connection
var server: WebSocketServer setget toss, deny
var client: WebSocketClient setget toss, deny
var player_name: String setget toss, get_player_name
puppet var peers: Array = []
puppet var myID: int = 1

func ready() -> void:
	# give the server access to puppet functions and variables
	set_network_master(1)

func client_server(port: int, player_name: String) -> void:
	print("Starting server on port ", port, " with host player name ", player_name)
	connection = Connection.CLIENT_SERVER
	self.player_name = player_name
	server = WebSocketServer.new()
	server.listen(port, PoolStringArray(), true) #3rd input must be true to use Godot's high level networking API
	get_tree().set_network_peer(server)
	connect_signals()
	get_tree().change_scene("res://assets/main/main.tscn")

func client(hostName: String, port: int, player_name: String) -> void:
	print("Connecting to server ", hostName, " on port ", port, " with host player name ", player_name)
	connection = Connection.CLIENT
	self.player_name = player_name
	client = WebSocketClient.new()
	#use "ws://" at the beginning of address for websocket connections
	var url: String = "ws://" + hostName + ":" + str(port)
	# 3rd argument true means use Godot's high level networking API
	var _error: int = client.connect_to_url(url, PoolStringArray(), true)
	if (_error):
		print("Error when connecting to server: ", _error)
		get_tree().quit()
		
	get_tree().set_network_peer(client)
	connect_signals()
	#do not switch to main scene here, wait until the connection was successful

func _player_connected(id) -> void:
	peers.append(id)
	if get_tree().is_network_server():
		# remotely set myID var of new player to their network id
		rset_id(id, "myID", str(id))
		# sync peer list of all players
		rset("peers", peers)

func _player_disconnected(id) -> void:
	peers.erase(id)
	rset("peers", peers) #syncs peer list of all players

func _connected_to_server() -> void:
	print("Connection to server succeeded")
	get_tree().change_scene("res://assets/main/main.tscn")
	pass #here is where you would put stuff that happens when you connect, such as switching to a lobby scene

func _connection_failed() -> void:
	print("Connection to server failed")
	pass #here is where you would handle the fact that the connection failed

func _server_disconnected() -> void:
	print("server disconnected")
	pass #this is called when the player is kicked, when the server crashes, or whenever the connection is severed

func _process(_delta) -> void:
	if server != null:			#since this is a websocket connection, it must be manually polled
		if server.is_listening():
			server.poll()
	elif client != null:
		if client.get_connection_status() == NetworkedMultiplayerPeer.CONNECTION_CONNECTED || client.get_connection_status() == NetworkedMultiplayerPeer.CONNECTION_CONNECTING:
			client.poll()

func toss(newValue) -> void:
	pass
	
func deny() -> void:
	pass

func get_connection() -> int:
	return connection

func connect_signals() -> void:
	get_tree().connect("network_peer_connected", self, "_player_connected")
	get_tree().connect("network_peer_disconnected", self, "_player_disconnected")
	get_tree().connect("connected_to_server", self, "_connected_to_server")
	get_tree().connect("connection_failed", self, "_connection_failed")
	get_tree().connect("server_disconnected", self, "_server_disconnected")

func get_player_name() -> String:
	return player_name
