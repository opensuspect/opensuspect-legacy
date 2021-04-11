extends Node

#this script will keep track of info about the player and what they can and can't do
#for instance, keeping track if they are in a menu in order to disable movement

var inMenu = false
var ourrole
var ournumber
var tasks = [-1]
var taskstoassign
var assignedtasks

# stores messages so they can be shown on multiple chatboxes
var chatbox_cache: Array

#vars for role assignment
#Percent assigns based on what % should be x role, Amount assigns given amount to x role
#mustAssign specifies if the role is mandatory to have, team specifies a team number which
#will be checked by the win condition scripts. When giving numbers out to the infiltrator
#teams, consider, that the majority count for elimination victory will favor the lower number
#in case of tie (check main.gd for details).
enum assignStyle {Percent, Amount}
var style: int = assignStyle.Percent
var enabledRoles: Array = ["traitor", "detective", "default"]
var roles: Dictionary = {"traitor": {"percent": float(2)/7, "amount": 1, "mustAssign": true, "team": 1}, 
						"detective": {"percent": float(1)/7, "amount": 1, "mustAssign": false, "team": 0}, 
						"default": {"percent": 0, "amount": 0, "mustAssign": false, "team": 0}}
var players: Dictionary = {}
var playerRoles: Dictionary = {}
var playerColors: Dictionary = {enabledRoles[0]: Color(1,0,0),# traitor
								enabledRoles[1]: Color(0,0,1),# detective
								enabledRoles[2]: Color(1,1,1)}# default
var rng = RandomNumberGenerator.new()
signal roles_assigned

func _ready():
	set_network_master(1)
# warning-ignore:return_value_discarded
	GameManager.connect("state_changed_priority", self, "state_changed_priority")

func assigntasks():
	for id in Network.peers:
		taskstoassign = tasks
		for task in taskstoassign:
			if task == -1:
				rng.randomize()
				taskstoassign[task] = rng.randi_range(-1,0)
				print("task assigned,",taskstoassign[task])
		if id == 1:
			assignedtasks = taskstoassign
			print("host tasks assigned",taskstoassign)
		else:
			rpc_id(id,"gettasks",taskstoassign)
			print("client tasks assigned",taskstoassign)

remote func gettasks(tasksget):
	assignedtasks = tasksget
	print("we got our tasks!")

# warning-ignore:unused_argument
func state_changed_priority(old_state: int, new_state: int, priority: int):
	if priority != 2:
		return
	match new_state:
		GameManager.State.Normal:
			assignRoles(Network.get_peers())
		GameManager.State.Lobby:
			#revoke special roles when players move to lobby
			for i in playerRoles.keys():
				playerRoles[i] = "default"
			emit_signal("roles_assigned", playerRoles)

func assignRoles(players: Array):
	if not get_tree().is_network_server():
		return
	print("assigning roles")
	playerRoles = {}
	var toAssign = players.duplicate() #duplicating to avoid linking to external array
	randomize() #randomizes seed
	toAssign.shuffle()
	#print(toAssign)
	var playerAmount = toAssign.size()
	assigntasks()

	#if using percent, find how many of each role to assign
	if style == assignStyle.Percent:
		for i in enabledRoles:
			if not roles.keys().has(i) or i == "default":
				continue
			#rounds down to be more predictable, if percent is 1/7th, role won't be assigned until there are 7 players
			roles[i].amount = roundDown(roles[i].percent * playerAmount, 1)
			if roles[i].amount < 1 and roles[i].mustAssign:
				roles[i].amount = 1

	# of players that aren't going to be assigned to a special role
	var defaults = playerAmount
	for i in enabledRoles:
		if not roles.keys().has(i) or i == "default":
			continue
		defaults -= roles[i].amount
	if defaults < 0:
		defaults = 0
	roles.default.amount = defaults
	#print("roles: ", roles)

	#actually assign roles
	for i in enabledRoles:
		if not roles.keys().has(i):
			continue
		for x in roles[i].amount:
			playerRoles[toAssign[0]] = i
			toAssign.erase(toAssign[0])
	print("roles assigned: ", playerRoles)
	rpc("receiveRoles", playerRoles)
	setourrole()

puppet func receiveRoles(newRoles):
	playerRoles = newRoles
	print("received roles: ", newRoles)
	setourrole()

func roundDown(num, step):
	var normRound = stepify(num, step)
	if normRound > num:
		return normRound - step
	return normRound

func get_main_player() -> KinematicBody2D:
	"""Gets the main player on the local client."""
	for player in players.values():
		if player.main_player:
			return player
	#There is no main player, the program runs as a dedicated server
	return null

func get_player_roles() -> Dictionary:
	"""Returns all players and their roles"""
	return playerRoles

func get_player_role(id) -> String:
	"""Returns the role name of the player with the requested id"""
	return playerRoles[id]

func get_player_team(id) -> int:
	"""Returns the team number of the player with the requested id"""
	return roles[playerRoles[id]]["team"]

func get_enabledRoles():
	"""Returns all roles that are enabled in the current game"""
	return enabledRoles

func get_enabledTeams() -> Array:
	"""Returns an array with the teams (numbered) enabled in the current game"""
	var teams: Array
	
	for role in roles:
		if teams.find(roles[role]["team"]) == -1:
			teams.append(roles[role]["team"])
	return teams

func setourrole():
	ourrole = PlayerManager.get_player_role(Network.myID)
	print(ourrole)
	emit_signal("roles_assigned", playerRoles)

signal message_received(sender, content, color)
signal message_received_server(sender, content, color)
signal bulk_messages_received(messages)

func send_message(content: String, color):
	print("message sent")
	if get_tree().is_network_server():
		# sender is 1 because the server always has a network ID of 1
		send_message_server(1, content, color)
	rpc_id(1, "receive_message_server", Network.get_my_id(), content, color)

# used by the server to sync messages, not to send messages written by the host player
func send_message_server(sender: int, content: String, color):
	print("message sent server")
	if not get_tree().is_network_server():
		return
	rpc("receive_message", sender, content, color)

puppet func receive_message(sender: int, content: String, color):
	print("message received")
	emit_signal("message_received", sender, content, color)

remote func receive_message_server(sender: int, content: String, color):
	print("message received server")
	if not get_tree().is_network_server():
		return
	if get_tree().get_rpc_sender_id() != sender:
		return
	emit_signal("message_received_server", sender, content, color)

func send_bulk_messages(messages):
	rpc("receive_bulk_messages", messages)

puppet func receive_bulk_messages(messages: Array):
	emit_signal("bulk_messages_received", messages)
