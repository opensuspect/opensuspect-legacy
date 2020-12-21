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
	if my_customization.empty():
		my_customization = randomAppearance()

func setPlayerAppearance(custmoization_data, id):
	"""
	This function only saves the received customization data at the proper id,
	it doesn't actually change the appearance of any player instance.
	"""
	customization_dict[id] = custmoization_data

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

master func queryPlayerData() -> void:
	"""The server asks all clients to send their customization data back."""
	if not get_tree().is_network_server():
		return
	rpc("sendCustomizationToServer")

remote func sendCustomizationToServer() -> void:
	"""Sends the actual customization data of the main player to the server."""
	print("I am ", Network.get_my_id(), ", sending my customization data to the server")
	rpc_id(1, "receiveCustomizationFromClient", customization_dict[Network.get_my_id()])

remote func receiveCustomizationFromClient(custmoization_data: Dictionary) -> void:
	"""
	Confirms that player data has been received on the server from the client.
	Sends this player data to all the other clients along with its own player data.
	"""
	print("receiveCustomizationFromClient")
	if not get_tree().is_network_server():
		return
	var id: int = get_tree().get_rpc_sender_id()
	print("I am ", Network.get_my_id(), " and received customization from ", id, ", broadcasting it to everyone.")
	customization_dict[id] = custmoization_data
	var playerInstance = PlayerManager.getPlayerById(id)
	if playerInstance != null:
		playerInstance.customizePlayer(custmoization_data)
	rpc("receiveCustomizationFromServer", id, custmoization_data)

puppet func receiveCustomizationFromServer(id: int, custmoization_data: Dictionary) -> void:
	"""Takes player data received from the server and applies them to the local player."""
	#TODO check whether the RPC was sent by the server or not
	if id == Network.get_my_id():
		return
	print("I am ", Network.get_my_id(), " and I received the customization of player ", id)
	setPlayerAppearance(id, custmoization_data)
	#add a SIGNAL to propmt application of the changed sprites if applicable

func randomAppearance():
	return null

func changeMyAppearance(custmoization_data) -> void:
	"""Called when the player changes their appearance in-game."""
	print("changeMyAppearance function was called")
	if custmoization_data != null:
		my_customization = custmoization_data
	if customization_change && Network.get_connection() != 0:
		setPlayerAppearance(Network.get_my_id(), my_customization)
		sendCustomizationToServer()
		#TODO send a SIGNAL to prompt application of the changed sprites
