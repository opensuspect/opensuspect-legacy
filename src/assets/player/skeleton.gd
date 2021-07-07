extends Node2D

# This dictionary contains the names of the nodes that will need to load the sprites
var player_sprite_names: Dictionary = {
	"Clothes": [
		"LeftArm",
		"LeftLeg",
		"Pants",
		"RightLeg",
		"Skeleton/Spine/Clothes",
		"RightArm"
	],
	"Body": ["Body"],
	"Facial Hair": ["Skeleton/Spine/FacialHair"],
	"Face Wear": ["Skeleton/Spine/FaceWear"],
	"Hat/Hair": ["Skeleton/Spine/HatHair"],
	"Mouth": ["Skeleton/Spine/Mouth"],
}
# This will contain the reference to the node instances showing the sprites
var sprite_nodes: Dictionary = {}
# The shader names
var custom_color_shaders: Dictionary = {
	"Skin Color": "skin_color", "Hair Color": "hair_color", "Facial Hair Color": "fhair_color"
	}

func _ready():
	var sprites: Array
	
	# Assign the nodes of the character to the variables for easy access
	for part in player_sprite_names.keys():
		sprites = []
		for sprite_name in player_sprite_names[part]:
			sprites.append(self.get_node(sprite_name))
		sprite_nodes[part] = sprites

func applyCustomization(customizationData):
	#----------
	# Receives the customization data, and applies it to the current instance.
	#----------
	if customizationData.empty():
		print_debug("Empty customization data received")
		return
	var color_for_shader: Color
	var file_paths: Array
	for shader_name in custom_color_shaders.keys():
		color_for_shader = Color(
			customizationData[shader_name]["r"],
			customizationData[shader_name]["g"],
			customizationData[shader_name]["b"])
		self.material.set_shader_param(custom_color_shaders[shader_name], color_for_shader)
	for part in sprite_nodes.keys():
		file_paths = AppearanceManager.getFilePaths(part, customizationData[part])
		for sprite_num in len(sprite_nodes[part]):
			# TODO: only run this if the texture has to be changed
			sprite_nodes[part][sprite_num].texture = load(file_paths[sprite_num])
