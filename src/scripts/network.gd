extends Node
enum Connection {
	LOCAL,				# Local only game, tutorial
	DEDICATED_SERVER,	# Server only, no local client
	CLIENT_SERVER,		# Server with a local player
	CLIENT				# Client only, remote server
}

var connection = Connection.LOCAL
var hostName: String = '' #name of host server
var ip: String = ''
var port: int = 0
var hosting: bool = false
var server
var client
puppet var peers: Array = [] #keeps track of network IDs of players
puppet var myID: int = 0

func ready():
	set_network_master(1) #gives the server access to puppet functions and variables
	#get_tree().connect("network_peer_connected", self, "_player_connected")			#moved to after network peer is created, was causing _connected_to_server() to never be called
	#get_tree().connect("network_peer_disconnected", self, "_player_disconnected")
	#get_tree().connect("connected_to_server", self, "_connected_to_server")
	#get_tree().connect("connection_failed", self, "_connection_failed")
	#get_tree().connect("server_disconnected", self, "_server_disconnected")

func server(typestr: String = "CLIENT_SERVER"):
	if typestr == "DEDICATED":
		connection = Connection.DEDICATED_SERVER
	elif typestr == "CLIENT_SERVER":
		connection = Connection.CLIENT_SERVER
	hosting = true
	client = null
	print("Starting server")
	server = WebSocketServer.new()
	server.listen(port, PoolStringArray(), true) #3rd input must be true to use Godot's high level networking API
	get_tree().set_network_peer(server)
	get_tree().connect("network_peer_connected", self, "_player_connected")
	get_tree().connect("network_peer_disconnected", self, "_player_disconnected")
	get_tree().connect("connected_to_server", self, "_connected_to_server")
	get_tree().connect("connection_failed", self, "_connection_failed")
	get_tree().connect("server_disconnected", self, "_server_disconnected")
	get_tree().change_scene("res://scenes/main.tscn")

func client(IPstr: String = hostName, typestr: String = "CLIENT"):
	if typestr == "CLIENT":
		connection = Connection.CLIENT
	else:
		connection = Connection.LOCAL
	hosting = false
	ip = IPstr
	server = null
	print("Connecting to ", hostName, " on port ", port)
	client = WebSocketClient.new()
	var url = "ws://" + ip + ":" + str(port) #use "ws://" at the beginning of address for websocket connections
	var _error = client.connect_to_url(url, PoolStringArray(), true) #3rd input must be true to use Godot's high level networking API
	get_tree().set_network_peer(client)
	get_tree().connect("network_peer_connected", self, "_player_connected")
	get_tree().connect("network_peer_disconnected", self, "_player_disconnected")
	get_tree().connect("connected_to_server", self, "_connected_to_server")
	get_tree().connect("connection_failed", self, "_connection_failed")
	get_tree().connect("server_disconnected", self, "_server_disconnected")
	#do not switch to main scene here, wait until the connection was successful

func _player_connected(id):
	peers.append(id)
	if get_tree().is_network_server():
		rset_id(id, "myID", str(id)) #remotely sets myID var of new player to their network id
		rset("peers", peers) #syncs peer list of all players

func _player_disconnected(id):
	peers.erase(id)
	rset("peers", peers) #syncs peer list of all players

func _connected_to_server():
	print("Connection to ", hostName, " on port ", port, " succeeded")
	get_tree().change_scene("res://scenes/main.tscn")
	pass #here is where you would put stuff that happens when you connect, such as switching to a lobby scene

func _connection_failed():
	print("Connection to ", hostName, " on port ", port, " failed")
	pass #here is where you would handle the fact that the connection failed

func _server_disconnected():
	print("server disconnected")
	pass #this is called when the player is kicked, when the server crashes, or whenever the connection is severed

func _process(_delta):
	if server != null:			#since this is a websocket connection, it must be manually polled
		if server.is_listening():
			server.poll()
	elif client != null:
		if client.get_connection_status() == NetworkedMultiplayerPeer.CONNECTION_CONNECTED || client.get_connection_status() == NetworkedMultiplayerPeer.CONNECTION_CONNECTING:
			client.poll()
