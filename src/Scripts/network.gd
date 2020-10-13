extends Node
enum Connection {
	LOCAL,				# Local only game, tutorial
	DEDICATED_SERVER,	# Server only, no local client
	CLIENT_SERVER,		# Server with a local player
	CLIENT				# Client only, remote server
}

var connection = Connection.LOCAL
var host: String = '' #not sure why this is needed or a string, server network ID will always be 1
var ip: String = ''
var port: int = 0
var hosting: bool = false
var server
var client
puppet var peers: Array = [] #keeps track of network IDs of players
puppet var myID: int = 0

func ready():
	set_network_master(1) #gives the server access to puppet functions and variables
	get_tree().connect("network_peer_connected", self, "_player_connected")
	get_tree().connect("network_peer_disconnected", self, "_player_disconnected")
	get_tree().connect("connected_to_server", self, "_connected_to_server")
	get_tree().connect("connection_failed", self, "_connection_failed")
	get_tree().connect("server_disconnected", self, "_server_disconnected")

func server(type: String = "DEDICATED"):
	if type == "DEDICATED":
		connection = Connection.DEDICATED_SERVER
	elif type == "CLIENT_SERVER":
		connection = Connection.CLIENT_SERVER
	hosting = true
	var server = WebSocketServer.new()
	server.listen(port, PoolStringArray(), true) #3rd input must be true to use Godot's high level networking API
	get_tree().set_network_peer(server)

func client(IPstr: String, type: String = "CLIENT"):
	if type == "CLIENT":
		connection = Connection.CLIENT
	else:
		connection = Connection.LOCAL
	hosting = false
	ip = IPstr
	var client = WebSocketClient.new()
	var url = "ws://" + ip + ":" + str(port) #use "ws://" at the beginning of address for websocket connections
	var error = client.connect_to_url(url, PoolStringArray(), true) #3rd input must be true to use Godot's high level networking API
	get_tree().set_network_peer(client)

func _player_connected(id):
	peers.append(id)
	rset_id(id, "myID", str(id)) #remotely sets myID var of new player to their network id
	rset("peers", peers) #syncs peer list of all players

func _player_disconnected(id):
	peers.erase(id)
	rset("peers", peers) #syncs peer list of all players

func _connected_to_server():
	pass #here is where you would put stuff that happens when you connect, such as switching to a lobby scene

func _connection_failed():
	pass #here is where you would handle the fact that the connection failed

func _server_disconnected():
	pass #this is called when the player is kicked, when the server crashes, or whenever the connection is severed

func _process(delta):
	if server != null:			#since this is a websocket connection, it must be manually polled
		if server.is_listening():
			server.poll()
	elif client != null:
		if client.get_connection_status() == NetworkedMultiplayerPeer.CONNECTION_CONNECTED || client.get_connection_status() == NetworkedMultiplayerPeer.CONNECTION_CONNECTING:
			client.poll()
