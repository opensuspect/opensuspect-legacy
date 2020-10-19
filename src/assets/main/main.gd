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
var errdc = false
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
		PlayerManager.ournumber = 0
	elif Network.connection == Network.Connection.CLIENT:
		get_tree().connect("network_peer_disconnected", self, "_player_disconnected")
		#print("Connecting to ", Network.host, " on port ", Network.port)
		#var peer = NetworkedMultiplayerENet.new()
		#peer.create_client(Network.host, Network.port)
		#get_tree().network_peer = peer

# Called on the server when a new client connects
func _player_connected(id):
	newnumber = Network.peers.size()
	rpc_id(id,"getname",id, version, newnumber)
	rpc_id(id,"serverinfo",Network.get_player_name(), version)
remote func serverinfo(sname,sversion):
	player_join(1,sname)
remote func getname(id,sversion,assignednumber):
	rpc_id(1,"playerjoin_proper",Network.get_player_name(),id)
	PlayerManager.ournumber = assignednumber
	if not version == sversion:
		print("HEY! YOU! YOU FORGOT TO UPDATE YOUR CLIENT. RE EXPORT AND TRY AGAIN!")
remote func playerjoin_proper(thename,id):
	var new_player = player_scene.instance()
	id = get_tree().get_rpc_sender_id()
	new_player.id = id
	new_player.ourname = thename
	new_player.main_player = false
	#print(thename)
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
	print(Network.peers.size())
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

signal clientstartgame
#since this code can only be triggered when the server presses the start game button, we will put task assignment or role assignment here
func _on_startgamebutton_gamestartpressed():
	print("game start triggered")
	serverassign()
	while intruders <= 2:
		var rng = RandomNumberGenerator.new()
		var isintruder = false
		rng.randomize()
		var my_random_number = rng.randi_range(0, Network.peers.size())
		#technically should generate a 1 in 10 chance of you being an intruder
		intruders = intruders + 1
		rpc("startgame",my_random_number)
		isintruder = false
	# TODO: Looser coupling here would be nice
	GameManager.state = GameManager.State.Normal

remote func startgame(intrudernumber):
	if intrudernumber == PlayerManager.ournumber:
		print("we are the intruder!")
		PlayerManager.isintruder = true
	else:
		print("we are not the intruder")
	emit_signal("clientstartgame")
func serverassign():
	var rng = RandomNumberGenerator.new()
	var isintruder = false
	rng.randomize()
	var my_random_number = rng.randf_range(0, Network.peers.size())
	print(my_random_number)
	if intruders <= 2 and my_random_number == 0:
		print("host is the intruder!")
		PlayerManager.isintruder = true
	else:
		print("we are not the intruder")
