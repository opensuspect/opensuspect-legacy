extends ControlBase

# Controls for changing parts
onready var part_selector_scene: PackedScene = preload("res://assets/ui/submenus/appearance_editor/part_selector.tscn")
onready var color_selector_scene: PackedScene = preload("res://assets/ui/submenus/appearance_editor/color_selector.tscn")

# Appearance editor nodes
onready var appearance_hbox: HBoxContainer = $MarginContainer/AppearanceHBox
onready var customization_vbox: VBoxContainer = appearance_hbox.get_node("CustomizationVBox")
onready var preview_buttons_vbox: VBoxContainer = appearance_hbox.get_node("PreviewButtonsVBox")
onready var player_container: CenterContainer = preview_buttons_vbox.get_node("PlayerContainer")
onready var buttons_hbox: HBoxContainer = preview_buttons_vbox.get_node("ButtonsHBox")
onready var root: Viewport = get_tree().get_root()

# Player preview nodes
onready var player_skeleton: Node2D = player_container.get_node("Skeleton")
onready var animator: AnimationPlayer = player_skeleton.get_node("AnimationPlayer")

enum Anim {IDLE, MOVE, DEATH}

# This dictionary contains the names of the nodes that will need to load the sprites
var player_sprite_names: Dictionary = {
	"Clothes": [
		"LeftArm",
		"LeftLeg",
		"Skeleton/Spine/Pants",
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

# This will contain the instances of the part selectors
var part_selectors: Dictionary = {}
# It will contain all the possible selectable file names
var part_selections: Dictionary = {}
# It will contain the currently displayed customization settings
var current_customization: Dictionary = {}
# The shader names
var custom_color_shaders: Dictionary = {
	"Skin Color": "skin_color", "Hair Color": "hair_color", "Facial Hair Color": "fhair_color"
}
# It will contain the custom color selector boxes
var color_selectors: Dictionary = {}

var viewport_texture_data: Image

func _ready() -> void:
	var part_selector: HBoxContainer
	var color_selector: Control
	var sprites: Array
	
	get_tree().get_root().connect("size_changed", self, "_on_root_size_changed")
	
	var player_parts = AppearanceManager.getPlayerParts()
	
	# Goes through the customizable colors and cretes the color selector UI elements
	for color_selector_name in custom_color_shaders.keys():
		color_selector = color_selector_scene.instance()
		color_selector.get_node("Label").text = color_selector_name
		color_selector.my_name = color_selector_name
		color_selector.color_map_image = AppearanceManager.getColorMap(color_selector_name)
		color_selector.connect("color_changed", self, "_on_choose_color")
		customization_vbox.add_child(color_selector)
		color_selectors[color_selector_name] = color_selector
	# Goes through the customizable body parts and creates the part selector UI elements
	for part in player_parts.keys():
		part_selections[part] = AppearanceManager.partFiles(part)
		part_selector = part_selector_scene.instance()
		part_selector.get_node("PartLabel").text = part
		for part_sprite in part_selections[part]:
			part_selector.parts.append(part_sprite)
		part_selector.get_node("CurrentPartLabel").text = part_selector.parts[0]
		part_selector.connect("part_changed", self, "_on_part_changed")
		customization_vbox.add_child(part_selector)
		part_selectors[part] = part_selector
	# Assign the sample character nodes to the variables for easy access
	for part in player_sprite_names.keys():
		sprites = []
		for sprite_name in player_sprite_names[part]:
			sprites.append(player_skeleton.get_node(sprite_name))
		sprite_nodes[part] = sprites

func _on_choose_color(new_color, part_name):
	"""Receives the selected color from the color selectors"""
	current_customization[part_name] = new_color
	_update_preview()

func _update_ui_elements():
	for part in part_selectors.keys():
		part_selectors[part].set_current_part(current_customization[part])
	for color_selector in color_selectors:
		color_selectors[color_selector].setColorTo(
			current_customization[color_selector]["x"],
			current_customization[color_selector]["y"])

func _update_preview() -> void:
	"""Updates the player preview with the currently selected customizations."""
	var color_for_shader: Color
	var file_paths: Array
	var player_parts = AppearanceManager.getPlayerParts()
	
	for shader_name in custom_color_shaders.keys():
		color_for_shader = Color(
			current_customization[shader_name]["r"],
			current_customization[shader_name]["g"],
			current_customization[shader_name]["b"])
		player_skeleton.material.set_shader_param(custom_color_shaders[shader_name], color_for_shader)

	for part in sprite_nodes.keys():
		file_paths = AppearanceManager.getFilePaths(part, current_customization[part])
		for sprite_num in len(sprite_nodes[part]):
			# TODO: only run this if the texture has to be changed
			sprite_nodes[part][sprite_num].texture = load(file_paths[sprite_num])

func open() -> void:
	show()
	_load()

func close() -> void:
	hide()

func _close_editor() -> void:
	"""Handle closing the editor differently depending on game state."""
	if GameManager.state == GameManager.State.Start:
		close()
	else:
		UIManager.close_ui("appearance_editor")

func _on_part_changed(new_part: String, part_name: String) -> void:
	var part_options: Array = part_selections[part_name]
	if not part_options.has(new_part):
		return
	current_customization[part_name] = new_part
	_update_preview()

func _on_Animations_item_selected(index: int) -> void:
	match index:
		Anim.IDLE:
			animator.play("idle")
		Anim.MOVE:
			animator.play("h_move")
		Anim.DEATH:
			animator.play("death")

func _on_CancelButton_pressed() -> void:
	_close_editor()

func _on_SaveButton_pressed() -> void:
	_save()
	_close_editor()

func _load() -> void:
	"""
	Asks for the player's appearance data from AppearanceManager and applies it
	to the preview.
	"""
	current_customization = AppearanceManager.getMyAppearance()
	_update_ui_elements()
	_update_preview()

func _save() -> void:
	"""Saves the player's selected appearance to player_data.save."""
	AppearanceManager.changeMyAppearance(current_customization)
	AppearanceManager.savePlayerAppearance()

func _on_RandomizeButton_pressed():
	current_customization = AppearanceManager.randomAppearance()
	current_customization = AppearanceManager.setColors(current_customization)
	_update_ui_elements()
	_update_preview()
