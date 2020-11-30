extends Node2D

export (int) var MAX_PLAYERS = 10
export (String, FILE, "*.tscn") var player_s = "res://assets/player/player.tscn"
var player_scene = load(player_s)
export (String, FILE, "*.tscn") var item_s = "res://assets/maps/common/item/item.tscn"
var item_scene = load(item_s)

var item_pos : Dictionary
var item_visible: Dictionary
var player_ids : Dictionary
var item_to_hold
var item_to_drop
var identity: int
var holder
var item_p = null
var new_item_pos 
#onready var player_scene = preload(player_s)
# Used on both sides, to keep track of all players.
var players = {}
#!!!THIS IS IMPORTANT!!!
#INCREASE THIS VARIABLE BY ONE EVERY COMMIT TO PREVENT OLD CLIENTS FROM TRYING TO CONNECT TO SERVERS!!!
var version = 13
var intruders = 0
var newnumber
var spawn_pos = Vector2(0,0)

signal positions_updated(last_received_input)
signal set_position

func _ready():
	set_network_master(1)

# Gets called when the title scene sets this scene as the main scene
func _enter_tree():
	if Network.connection == Network.Connection.CLIENT_SERVER:
# warning-ignore:return_value_discarded
		get_tree().connect("network_peer_disconnected", self, "_player_disconnected")
# warning-ignore:return_value_discarded
		Network.connect("connection_handled", self, "connection_handled")
		PlayerManager.ournumber = 0
		createPlayer(Network.get_my_id(), Network.get_player_name())
	elif Network.connection == Network.Connection.CLIENT:
# warning-ignore:return_value_discarded
		get_tree().connect("network_peer_disconnected", self, "_player_disconnected")

# Keep the clients' player positions updated
func _physics_process(_delta):
	if get_tree().is_network_server():
		var positions_dict = {}
		for id in players.keys():
			positions_dict[id] = [players[id].position, players[id].movement]
		for id in players.keys():
			if id != 1:
				rpc_id(id, "update_positions", positions_dict, players[id].input_number)

func connection_handled(id, playerName):
	print("connection handled, id: ", id, " name: ", playerName)
	if not get_tree().is_network_server():
		return
	rpc("checkVersion", version)
	newnumber = Network.peers.size()
	rpc_id(id, "receiveNumber", newnumber)
	#tell all existing players to create this player
	for i in players.keys():
		if i != id:
			print("telling ", i, " to create player ", id)
			rpc_id(i, "createPlayer", id, playerName, spawn_pos)
	#tell new player to create existing players
	print("telling ", id, " to create players")
	rpc_id(id, "createPlayers", Network.get_player_names())

puppet func checkVersion(sversion):
	if version != sversion:
		print("HEY! YOU! YOU FORGOT TO UPDATE YOUR CLIENT. RE EXPORT AND TRY AGAIN!")

puppet func receiveNumber(number):
	if get_tree().get_rpc_sender_id() != 1:
		return
	PlayerManager.ournumber = number

func _player_disconnected(id):
	players[id].queue_free() #deletes player node when a player disconnects
	players.erase(id)

#idNameDict should look like {<network ID>: <player name>}
puppetsync func createPlayers(idNameDict: Dictionary, spawnPointDict: Dictionary = {}):
	deletePlayers()
	for i in idNameDict.keys():
		if spawnPointDict.keys().has(i):
			#spawn at spawn point
			createPlayer(i, idNameDict[i], spawnPointDict[i])
		else:
			#else spawn at default spawn
			createPlayer(i, idNameDict[i], spawn_pos)

puppetsync func createPlayer(id: int, playerName: String, spawnPoint: Vector2 = Vector2(0,0)):
	print("creating player ", id)
	if players.keys().has(id):
		print("not creating player, already exists")
		return
	var newPlayer = player_scene.instance()
	newPlayer.id = id
	newPlayer.setName(playerName)
	player_ids[id] = playerName
	item_pos[playerName] = newPlayer.get_node("Reach/item_position")
	item_visible[playerName] = newPlayer.get_node("Reach")
	#newPlayer.set_network_master(id)
	if id == Network.get_my_id():
		newPlayer.main_player = true
		newPlayer.connect("main_player_moved", self, "_on_main_player_moved")
		self.connect("positions_updated", newPlayer, "_on_positions_updated")
	players[id] = newPlayer
	$players.add_child(newPlayer)
	newPlayer.move_to(spawnPoint, Vector2(0,0))
	print("New player: ", id)

func deletePlayers():
	for i in players.keys():
		players[i].queue_free()
	players.clear()

# Called from client side to tell the server about the player's actions
remote func player_moved(new_movement, last_input):
	# Should only be run on the server
	if !get_tree().is_network_server():
		return
	var id = get_tree().get_rpc_sender_id()
	if not players.keys().has(id):
		return
	# Check movement validity
	if new_movement.length() > 1:
		new_movement = new_movement.normalized()
	players[id].movement = new_movement
	players[id].input_number = last_input

# Called from server when the server's players move
puppet func update_positions(positions_dict, last_received_input):
	for id in positions_dict.keys():
		if players.keys().has(id):
			players[id].move_to(positions_dict[id][0], positions_dict[id][1])
	emit_signal("positions_updated", last_received_input)

func _on_main_player_moved(movement : Vector2, last_input : int):
	if not get_tree().is_network_server():
		rpc_id(1, "player_moved", movement, last_input)

master func _on_maps_spawn(spawnPositions: Array):
	if not get_tree().is_network_server():
		return
	spawn_pos = spawnPositions[0]
	#generate spawn point dict
	var spawnPointDict: Dictionary = {}
	for i in players.keys().size():
		spawnPointDict[players.keys()[i]] = spawnPositions[i % spawnPositions.size()]
		if spawnPointDict[players.keys()[i]] == null:
			spawnPointDict[players.keys()[i]] = spawn_pos
	#spawn players
	rpc("createPlayers", Network.get_player_names(), spawnPointDict)

func _process(delta):
	#for cast in item_visible:
	if item_visible.get(Network.get_player_name()).is_colliding():
		item_to_hold = item_scene.instance()
		print("this works")
	else:
		item_to_hold = null
		print("not work")
			
	if item_pos.get(Network.get_player_name()).get_child(0):
		if item_pos.get(Network.get_player_name()).get_child(0).item_name == "item":
			item_to_drop = item_scene.instance()
			#var sub = item_scene.instance()
			#$items.add_child(sub)
		else:
			item_to_drop = null
		
	if new_item_pos != null and item_p != null:
		new_item_pos.global_transform = item_p.global_transform


func _input(event):
	if Input.is_action_pressed("ui_pick"):
		if identity == 0 or 1:
			identity +=1
			if item_to_hold != null:
				if item_pos.get(Network.get_player_name()).get_child(0):
					get_parent().add_child(item_to_drop)
					item_to_drop.global_transform = item_pos.get(Network.get_player_name()).global_transform
					item_to_drop.pick = false
					item_pos.get(Network.get_player_name()).get_child(0).queue_free()
				item_visible.get(Network.get_player_name()).get_collider().queue_free()
				item_to_hold.pick = true
				item_pos.get(Network.get_player_name()).add_child(item_to_hold)
				print(item_pos.get(Network.get_player_name()).global_transform)
				rpc("set_item_pos")



remote func set_item_pos():
	var player_id = get_tree().get_rpc_sender_id()
	var name = Network.names.get(player_id)
	item_p = item_pos.get(name)
	var source = item_scene.instance()
	new_item_pos = Position2D.new()
	print(item_p.global_transform)
	print(new_item_pos.global_transform)
	$items.add_child(new_item_pos)
	new_item_pos.add_child(source)
	source.pick = true
	
	
	
	
	
	
	
	
#	var vector = Vector2(0,0)
#	print(item_p)
#	vector = item_p
#	print(vector)
#	$items.set_position(vector) 
#	print(item_p)
#	print($items.position)
#	$items.add_child(source)
	#item_pos.get
