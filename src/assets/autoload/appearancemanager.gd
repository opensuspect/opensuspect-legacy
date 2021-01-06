extends Node
"""
This autoload script is keeping persistent information about the customized
appearance of players so when the actual player nodes (or other nodes
representing the players) are instanced, the information is available at one
place.
"""
const customization_path : String = "user://player_data.save"
var customization_dict: Dictionary
var my_customization: Dictionary
var customization_change: bool = true

signal apply_appearance(id)

func _ready():
	"""
	When this script is ready, it loads the saved customization of the user.
	"""
	my_customization = SaveLoadHandler.load_data(customization_path)
	if my_customization.empty():
		my_customization = randomAppearance()
	GameManager.connect("state_changed_priority", self, "_on_state_changed_priority")

func enableMyAppearance():
	setPlayerAppearance(Network.get_my_id(), my_customization)

func enableAppearance(id: int):
	emit_signal("apply_appearance", id)

func enableAllAppearances():
	for id in customization_dict.keys():
		enableAppearance(id)

func setPlayerAppearance(id: int, custmoization_data: Dictionary):
	"""
	This function only saves the received customization data at the proper id.
	"""
	customization_dict[id] = custmoization_data
	emit_signal("apply_appearance", id)

func getPlayerAppearance(id):
	"""
	The customization details of the requested players are returned.
	"""
	if customization_dict.has(id):
		return customization_dict[id]
	return null

func savePlayerAppearance():
	"""
	Saves the visual appearance of the player to the file.
	"""
	pass

master func queryCustomization(id: int) -> void:
	"""The server asks a client to send their customization data back."""
	if not get_tree().is_network_server():
		return
	rpc_id(id, "sendCustomizationToServer")

remote func sendCustomizationToServer() -> void:
	"""Sends the actual customization data of the main player to the server."""
	print("I am ", Network.get_my_id(), ", sending my customization data to the server")
	rpc_id(1, "receiveCustomizationFromClient", customization_dict[Network.get_my_id()])

remotesync func receiveCustomizationFromClient(custmoization_data: Dictionary) -> void:
	"""
	Confirms that player data has been received on the server from the client.
	Sends this player data to all the other clients along with its own player data.
	"""
	if not get_tree().is_network_server():
		return
	var id: int = get_tree().get_rpc_sender_id()
	#If customization is not changable AND this player's customization is
	#already registered, don't broadcast
	if not customization_change and customization_dict.has(id):
		return
	setPlayerAppearance(id, custmoization_data)
	rpc("receiveCustomizationFromServer", id, custmoization_data)

puppet func receiveCustomizationFromServer(id: int, custmoization_data: Dictionary) -> void:
	"""Takes player data received from the server and applies them to the local player."""
	if get_tree().get_rpc_sender_id() != 1:
		return
	if id == Network.get_my_id():
		return
	setPlayerAppearance(id, custmoization_data)

remote func receiveBulkCustomization(received_customizatios: Dictionary):
	"""Receives multiple customization data from the server and merges it with
	the local dictionary"""
	if get_tree().get_rpc_sender_id() != 1:
		return
	for player in received_customizatios.keys():
		if player != Network.get_my_id():
			setPlayerAppearance(player, received_customizatios[player])

func sendBulkCustomization(id: int):
	"""Sends the whole customization dictionary to the relevant player"""
	if not get_tree().is_network_server():
		return
	rpc_id(id, "receiveBulkCustomization", customization_dict)

func randomAppearance():
	"""
	TODO: actually make it random. rightnow it's a preset
	"""
	print("appearancemanager.gd/randomappearance: loading data")
	return SaveLoadHandler.load_data("res://assets/common/settings/player_data.save")

func changeMyAppearance(custmoization_data) -> void:
	"""Called when the player changes their appearance in-game."""
	if custmoization_data != null:
		my_customization = custmoization_data
	if customization_change && Network.get_connection() != 0:
		enableMyAppearance()
		sendCustomizationToServer()

func getMyAppearance() -> Dictionary:
	return my_customization

func _on_state_changed_priority(old_state: int, new_state: int, priority: int) -> void:
	if priority != 5:
		return
	if new_state == GameManager.State.Lobby:
		customization_change = true
		enableMyAppearance()
		sendCustomizationToServer()
	elif new_state == GameManager.State.Start:
		customization_change = true
	else:
		customization_change = false
