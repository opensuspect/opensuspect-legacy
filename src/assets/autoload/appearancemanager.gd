extends Node
"""
This autoload script is keeping persistent information about the customized
appearance of players so when the actual player nodes (or other nodes
representing the players) are instanced, the information is available at one
place.
"""
# Location of the saved customization
const customization_path : String = "user://custom_appearance.save"
# Variables that manage the in-game appearance of the player character
var customization_dict: Dictionary
var my_customization: Dictionary
var customization_change: bool = true
# Variables that store the location of files used for appearance editing
var sprites_dir = "res://assets/player/textures/characters/customizable/"
var player_parts: Dictionary = {
	"Clothes": [
		"01-left-arm",
		"04-left-leg",
		"05-pants",
		"06-right-leg",
		"07-clothes",
		"08-right-arm",
	],
	"Body": ["02-body"],
	"Facial Hair": ["09-facial-hair"],
	"Face Wear": ["10-face-wear"],
	"Hat/Hair": ["11-hat-hair"],
	"Mouth": ["03-mouth"],
}
var custom_color_files: Dictionary = {
	"Skin Color": "skin_color", "Hair Color": "hair_color", "Facial Hair Color": "facial_hair_color"
	}
# This will control the color maps for each customizable color
var custom_colors: Dictionary = {}
# The selected colors should be stored as X-Y coordinates on the color map 0-499
const COLOR_XY = 500

signal apply_appearance(id)

func _ready():
	"""
	When this script is ready, it loads the saved customization of the user.
	"""
	var color_map: Image
	var texture: StreamTexture
	for color_map_name in custom_color_files.keys():
		texture = load(sprites_dir + custom_color_files[color_map_name] + ".png")
		color_map = texture.get_data()
		custom_colors[color_map_name] = color_map
	
	my_customization = SaveLoadHandler.load_data(customization_path)
	if my_customization.empty():
		my_customization = randomAppearance()
	my_customization = setColors(my_customization)

	GameManager.connect("state_changed_priority", self, "_on_state_changed_priority")

#-------------------------------------------------------------------------------
# Functions related to handling the low-level appearance modifications such as
# handling the sprite files, etc.
#-------------------------------------------------------------------------------

func getColorMap(color_map_name: String):
	"""Returns the custom color map by the name"""
	if custom_color_files.has(color_map_name):
		return custom_colors[color_map_name]
	return null

func getFilePaths(part_name: String, selection_name: String):
	"""
	Returns all the file names that are related to a certain customization of a 
	part: part_name is the high-level, uniquely customizable part, while selection_name
	is the name of the selection for the certain part.
	"""
	var paths = []
	var directory: String
	
	if not player_parts.has(part_name):
		return []
	for directory_num in len(player_parts[part_name]):
		directory = player_parts[part_name][directory_num]
		paths.append(sprites_dir + directory + "/" + selection_name + ".png")
	return paths

func getPlayerParts():
	return player_parts

func partFiles(part: String) -> Array:
	"""
	Returns an array of file names that are available for the part customization
	"""
	var dirname: String
	var files: Array = []
	var available_values: Array = []
	if not player_parts.has(part):
		return []
	dirname = sprites_dir + player_parts[part][0]
	files = Helpers.list_directory(dirname)
	available_values = []
	for file in files:
		# Skip PNG files. We will instead be modifying the PNG import file
		# names because PNG resource files aren't saved on export.
		if not file.ends_with("png"):
			available_values.append(file.replace(".png.import", ""))
	return available_values

func colorFromMapXY(color_map, x_rel, y_rel):
	"""
	Returns the color of the color map at x_rel, y_rel relative coordinates where
	both x_rel and y_rel are in the range of [0..COLOR_XY]
	"""
	var max_x: int
	var max_y: int
	var x: int
	var y: int
	var rgba: Color
	max_x = color_map.get_width()
	max_y = color_map.get_height()
	x = int(float(x_rel) / COLOR_XY * max_x)
	y = int(float(y_rel) / COLOR_XY * max_y)
	color_map.lock()
	rgba = color_map.get_pixel(x, y)
	color_map.unlock()
	return rgba

func setColors(customization):
	"""
	Based on the coordinates on the color maps, it adds rgb values to the customization
	dictionary received.
	"""
	var rgba: Color
	for color_map_name in custom_colors.keys():
		rgba = colorFromMapXY(custom_colors[color_map_name],
			customization[color_map_name]["x"],
			customization[color_map_name]["y"])
		customization[color_map_name]["r"] = rgba.r
		customization[color_map_name]["g"] = rgba.g
		customization[color_map_name]["b"] = rgba.b
	return customization

func randomAppearance():
	var available_values: Array = []
	var customization: Dictionary = {}
	var colors: Dictionary = {}
	for part in player_parts.keys():
		available_values = partFiles(part)
		customization[part] = Helpers.pick_random(available_values)
	for color_map_name in custom_colors.keys():
		colors["x"] = randi() % COLOR_XY
		colors["y"] = randi() % COLOR_XY
		customization[color_map_name] = colors.duplicate()
	return customization

#-------------------------------------------------------------------------------
# Functions related to handling the high-level appearance modifications during
# gameplay, including the server-client distribution
#-------------------------------------------------------------------------------

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
	SaveLoadHandler.save_data(customization_path, my_customization)

func queryCustomization(id: int) -> void:
	"""The server asks a client to send their customization data back."""
	if not get_tree().is_network_server():
		return
	rpc_id(id, "sendCustomizationToServer")

puppet func sendCustomizationToServer() -> void:
	"""Sends the actual customization data of the main player to the server."""
	print("I am ", Network.get_my_id(), ", sending my customization data to the server")
	rpc_id(1, "receiveCustomizationFromClient", customization_dict[Network.get_my_id()])

master func receiveCustomizationFromClient(custmoization_data: Dictionary) -> void:
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

puppet func receiveBulkCustomization(received_customizatios: Dictionary):
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

func changeMyAppearance(custmoization_data) -> void:
	"""Called when the player changes their appearance in-game."""
	if custmoization_data != null:
		my_customization = custmoization_data
	if customization_change && Network.get_connection() != 0:
		enableMyAppearance()
		sendCustomizationToServer()

func getMyAppearance() -> Dictionary:
	return my_customization.duplicate()

func _on_state_changed_priority(old_state: int, new_state: int, priority: int) -> void:
	if priority != 5:
		return
	print("(appearancemanager.gd/_on_state_changed_priority)")
	if new_state == GameManager.State.Lobby:
		customization_change = true
		enableMyAppearance()
		sendCustomizationToServer()
	elif new_state == GameManager.State.Start:
		customization_change = true
	else:
		customization_change = false
