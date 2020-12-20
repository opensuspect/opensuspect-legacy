extends Node
"""
This autoload script is keeping persistent information about the customized
appearance of players so when the actual player nodes (or other nodes
representing the players) are instanced, the information is available at one
place.
"""
const customization_path : String = "user://character_customization.save"
var customization_dict: Dictionary
var my_customization: Dictionary
var customization_change: bool = true

func _ready():
	"""
	When this script is first run, it loads the saved customization of the user.
	"""
	my_customization = SaveLoadHandler.load_data(customization_path)
	customization_dict[Network.get_my_id()] = my_customization.duplicate()

func setPlayerAppearance(custmoization_data, id):
	"""
	The look of a player is added stored in the list of available players, 
	and if the player does not exist, it is added to the dictionary.
	"""
	var playerInstance = PlayerManager.getPlayerById(id)
	if playerInstance != null:
		playerInstance.customizePlayer(custmoization_data)
		customization_dict[id] = custmoization_data

func getPlayerAppearance(id):
	"""
	The customization details of the requested players are returned.
	"""
	return customization_dict[id]

func savePlayerAppearance():
	"""
	Saves the visual appearance of the player to the file.
	"""
	pass

master func queryPlayerData() -> void:
	"""The server asks all clients to send their customization data back."""
	if not get_tree().is_network_server():
		return
	rpc("sendCustomizationToServer")

remote func sendCustomizationToServer() -> void:
	"""Sends the actual customization data of the main player to the server."""
	rpc_id(1, "receiveCustomizationFromClient", customization_dict[Network.get_my_id()])

master func receiveCustomizationFromClient(custmoization_data: Dictionary) -> void:
	"""
	Confirms that player data has been received on the server from the client.
	Sends this player data to all the other clients along with its own player data.
	"""
	if not get_tree().is_network_server():
		return
	var id: int = get_tree().get_rpc_sender_id()
	customization_dict[id] = custmoization_data
	var playerInstance = PlayerManager.getPlayerById(id)
	if playerInstance != null:
		playerInstance.customizePlayer(custmoization_data)
	rpc("receiveCustomizationFromServer", id, custmoization_data)

puppet func receiveCustomizationFromServer(id: int, custmoization_data: Dictionary) -> void:
	"""Takes player data received from the server and applies them to the local player."""
	if id == Network.get_my_id():
		return
	setPlayerAppearance(id, custmoization_data)

func _on_appearance_saved() -> void:
	"""Called when the player changes their appearance in-game."""
	my_customization = SaveLoadHandler.load_data(customization_path)
	if customization_change:
		customization_dict[Network.get_my_id()] = my_customization.duplicate()
	sendCustomizationToServer()
