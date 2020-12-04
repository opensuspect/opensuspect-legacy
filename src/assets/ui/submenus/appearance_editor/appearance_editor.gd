extends Control

onready var part_selector_scene: PackedScene = preload("res://assets/ui/submenus/appearance_editor/part_selector.tscn")

onready var appearance_hbox: HBoxContainer = $MarginContainer/AppearanceHBox
onready var customization_vbox: VBoxContainer = appearance_hbox.get_node("CustomizationVBox")
onready var skin_color_selector: Control = customization_vbox.get_node("SkinColorSelector")
onready var skin_tone_range: TextureRect = skin_color_selector.get_node("SkinToneRange")
onready var skin_color_range: TextureRect = skin_color_selector.get_node("SkinColorRange")
onready var cursor: Sprite = skin_color_selector.get_node("Cursor")
onready var color_preview: ColorRect = cursor.get_node("ColorPreview")
onready var preview_buttons_vbox: VBoxContainer = appearance_hbox.get_node("PreviewButtonsVBox")
onready var player: KinematicBody2D = preview_buttons_vbox.get_node("PlayerContainer/Player")
onready var buttons_hbox: HBoxContainer = preview_buttons_vbox.get_node("ButtonsHBox")
onready var root: Viewport = get_tree().get_root()

onready var player_left_leg: Polygon2D
onready var player_left_arm: Polygon2D
onready var player_body: Polygon2D
onready var player_clothes: Sprite
onready var player_pants: Sprite
onready var player_facial_hair: Sprite
onready var player_face_wear: Sprite
onready var player_hat_hair: Sprite
onready var player_mouth: Sprite
onready var player_right_leg: Polygon2D
onready var player_right_arm: Polygon2D

export (String) var player_parts_prefix := "res://assets/player/textures/characters/customizable"
export (Array, String) var player_parts_directories := [
	"01-left-arm",
	"02-body",
	"03-mouth",
	"04-left-leg",
	"05-pants",
	"06-right-leg",
	"07-clothes",
	"08-right-arm",
	"09-facial-hair",
	"10-face-wear",
	"11-hat-hair",
]

var player_part_options: Dictionary = {
	"Clothes": [],
	"Facial Hair": [],
	"Face Wear": [],
	"Hat/Hair": [],
	"Mouth": [],
}

var selected_skin_color: Color
var selecting_skin_color: bool

class PlayerPart:
	var part_group: String
	var texture: Texture
	var texture_path: String

class PartOption:
	var part_name: String
	var part_texture: Texture

class PlayerClothes extends PartOption:
	var left_leg_texture: Texture
	var left_arm_texture: Texture
	var right_leg_texture: Texture
	var right_arm_texture: Texture
	var clothes_texture: Texture
	var pants_texture: Texture

func _ready() -> void:
	# Center cursor in the middle of the skin color picker
	cursor.position = skin_color_selector.rect_position + (skin_color_selector.rect_size / 2.0)

	var player_parts_paths: Array = []
	for player_parts_directory in player_parts_directories:
		player_parts_paths.append(Helpers.string_join([player_parts_prefix, player_parts_directory], "/"))

	var player_parts: Array = []
	for path in player_parts_paths:
		var files: Array = _list_directory(path)
		for file in files:
			if file.ends_with("import"):
				continue
			var part_group: String = file.replace(".png", "")
			var texture_path: String = Helpers.string_join([path, file], "/")
			var player_part := PlayerPart.new()
			player_part.part_group = part_group
			player_part.texture = load(texture_path)
			player_part.texture_path = texture_path
			player_parts.append(player_part)

	var grouped_player_parts: Dictionary = {}
	for part in player_parts:
		if grouped_player_parts.has(part.part_group):
			grouped_player_parts[part.part_group].append(part)
		else:
			grouped_player_parts[part.part_group] = [part]

	var part_options: Dictionary = {}
	for grouped_part in grouped_player_parts:
		# Player clothes are grouped together
		if len(grouped_player_parts[grouped_part]) > 1:
			var player_clothes := PlayerClothes.new()
			for part in grouped_player_parts[grouped_part]:
				if "left" in part.texture_path:
					if "arm" in part.texture_path:
						player_clothes.left_arm_texture = part.texture
					elif "leg" in part.texture_path:
						player_clothes.left_leg_texture = part.texture
				elif "right" in part.texture_path:
					if "arm" in part.texture_path:
						player_clothes.right_arm_texture = part.texture
					elif "leg" in part.texture_path:
						player_clothes.right_leg_texture = part.texture
				elif "clothes" in part.texture_path:
					player_clothes.clothes_texture = part.texture
					player_clothes.part_name = part.part_group
				elif "pants" in part.texture_path:
					player_clothes.pants_texture = part.texture
			player_part_options["Clothes"].append(player_clothes)
		else:
			var part: PlayerPart = grouped_player_parts[grouped_part][0]
			var part_option := PartOption.new()
			part_option.part_name = part.part_group
			part_option.part_texture = part.texture
			if "facial" in part.texture_path.to_lower() and "hair" in part.texture_path.to_lower():
				player_part_options["Facial Hair"].append(part_option)
			elif "face" in part.texture_path.to_lower() and "wear" in part.texture_path.to_lower():
				player_part_options["Face Wear"].append(part_option)
			elif "hat" in part.texture_path.to_lower() and "hair" in part.texture_path.to_lower():
				player_part_options["Hat/Hair"].append(part_option)
			elif "mouth" in part.texture_path.to_lower():
				player_part_options["Mouth"].append(part_option)

	for part_option in player_part_options:
		var part_selector: HBoxContainer = part_selector_scene.instance()
		part_selector.get_node("PartLabel").text = part_option
		for part in player_part_options[part_option]:
			part_selector.parts.append(part.part_name)
		part_selector.get_node("CurrentPartLabel").text = part_selector.parts[0]
		part_selector.connect("part_changed", self, "_on_part_changed")
		customization_vbox.add_child(part_selector)

	player.get_node("Camera2D").queue_free()
	player.set_scale(Vector2.ONE * 5.0)
	var skeleton: Node2D = player.get_node("Skeleton")
	player_left_leg = skeleton.get_node("LeftLeg")
	player_left_arm = skeleton.get_node("LeftArm")
	player_body = skeleton.get_node("Body")
	player_right_leg = skeleton.get_node("RightLeg")
	player_right_arm = skeleton.get_node("RightArm")
	var spine: Bone2D = skeleton.get_node("Skeleton/Spine")
	player_clothes = spine.get_node("Clothes")
	player_pants = spine.get_node("Pants")
	player_facial_hair = spine.get_node("FacialHair")
	player_face_wear = spine.get_node("FaceWear")
	player_hat_hair = spine.get_node("HatHair")
	player_mouth = spine.get_node("Mouth")

func _list_directory(path: String, recursive: bool = false) -> Array:
	var directory := Directory.new()
	assert(directory.open(path) == OK)
	var files: Array = []
	directory.list_dir_begin(true)
	var file_name: String = directory.get_next()
	while file_name != "":
		if directory.current_is_dir() and recursive:
			_list_directory(file_name, recursive)
		else:
			files.append(file_name)
		file_name = directory.get_next()
	return files

func _choose_skin_color(coords: Vector2) -> void:
	if coords.x > 1 and coords.x < skin_color_selector.rect_size.x - 1 and \
	   coords.y > 1 and coords.y < skin_color_selector.rect_size.y - 1:
		color_preview.show()
		var viewport_texture_data: Image = get_viewport().get_texture().get_data()
		var offset: Vector2 = skin_color_selector.rect_global_position
		viewport_texture_data.flip_y()
		viewport_texture_data.lock()
		selected_skin_color = viewport_texture_data.get_pixelv(coords)
		cursor.set_position(coords)
		color_preview.color = selected_skin_color
		player_body.modulate = selected_skin_color
	else:
		color_preview.hide()

func _on_SkinColorSelector_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT:
		selecting_skin_color = event.pressed
		_choose_skin_color(event.position)
		if not event.pressed:
			color_preview.hide()
	elif selecting_skin_color and event is InputEventMouseMotion:
		_choose_skin_color(event.position)

func _on_part_changed(new_part: String, part_name: String) -> void:
	var part_options: Array = player_part_options[part_name]
	var part_option: PartOption = null
	for option in part_options:
		if option.part_name == new_part:
			part_option = option
	if part_option == null:
		return
	match part_name:
		"Clothes":
			player_left_leg.texture = part_option.left_leg_texture
			player_left_arm.texture = part_option.left_arm_texture
			player_right_leg.texture = part_option.right_leg_texture
			player_right_arm.texture = part_option.right_arm_texture
			player_clothes.texture = part_option.clothes_texture
			player_pants.texture = part_option.pants_texture
		"Facial Hair":
			player_facial_hair.texture = part_option.part_texture
		"Face Wear":
			player_face_wear.texture = part_option.part_texture
		"Hat/Hair":
			player_hat_hair.texture = part_option.part_texture
		"Mouth":
			player_mouth.texture = part_option.part_texture

func _on_CancelButton_pressed() -> void:
	pass # Replace with function body.

func _on_SaveButton_pressed() -> void:
	pass # Replace with function body.
