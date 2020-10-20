extends Node

#this script will keep track of info about the player and what they can and can't do
#for instance, keeping track if they are in a menu in order to disable movement

var inMenu = false
var isintruder = false
var ournumber

#vars for role assignment
#Percent assigns based on what % should be x role, Amount assigns given amount to x role
enum assignStyle {Percent, Amount}
var style: int = assignStyle.Percent
var enabledRoles: Array = ["traitor", "detective", "default"]
var roles: Dictionary = {"traitor": {"percent": float(2)/7, "amount": 1, "critical": true}, 
						"detective": {"percent": float(1)/7, "amount": 1, "critical": false}, 
						"default": {"percent": 0, "amount": 0, "critical": false}}
var playerRoles: Dictionary = {}

signal roles_assigned

func _ready():
	set_network_master(1)
	GameManager.connect("state_changed", self, "state_changed")

func state_changed(old_state, new_state):
	if new_state == GameManager.State.Normal:
		assignRoles(Network.get_peers())

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

	#if using percent, find how many of each role to assign
	if style == assignStyle.Percent:
		for i in enabledRoles:
			if not roles.keys().has(i) or i == "default":
				break
			#rounds down to be more predictable, if percent is 1/7th, role won't be assigned until there are 7 players
			roles[i].amount = roundDown(roles[i].percent * playerAmount, 1)
			if roles[i].amount < 1 and roles[i].critical:
				roles[i].amount = 1

	# of players that aren't going to be assigned to a special role
	var defaults = playerAmount
	for i in enabledRoles:
		if not roles.keys().has(i) or i == "default":
			break
		defaults -= roles[i].amount
	if defaults < 0:
		defaults = 0
	roles.default.amount = defaults
	#print("roles: ", roles)

	#actually assign roles
	for i in enabledRoles:
		if not roles.keys().has(i):
			break
		for x in roles[i].amount:
			playerRoles[toAssign[0]] = i
			toAssign.erase(toAssign[0])
	print("roles assigned: ", playerRoles)
	rpc("receiveRoles", playerRoles)
	emit_signal("roles_assigned", playerRoles)

puppet func receiveRoles(newRoles):
	playerRoles = newRoles
	print("received roles: ", newRoles)
	emit_signal("roles_assigned", playerRoles)

func roundDown(num, step):
	var normRound = stepify(num, step)
	if normRound > num:
		return normRound - step
	return normRound

func get_player_roles() -> Dictionary:
	return playerRoles
