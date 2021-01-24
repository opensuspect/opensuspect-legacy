extends Control

var my_name: String
onready var colormap_box: Node2D = self.get_node("ColorMapBox")
onready var colormap: Sprite = colormap_box.get_node("Colormap")
onready var cursor: Sprite = colormap_box.get_node("Cursor")
onready var preview_border: ColorRect = cursor.get_node("PreviewBorder")
onready var color_preview: ColorRect = preview_border.get_node("ColorPreview")
onready var label: Label = self.get_node("Label")
var color_map_image: Image
var coord_rel: Vector2
var color_map_y

signal color_changed(new_color_coords, part_name)

func _ready():
	coord_rel.x = 0
	coord_rel.y = 0
	setupColorSelector()

func setupSize():
	var map_width = color_map_image.get_width()
	var map_heigth = color_map_image.get_height()
	var window_width = self.rect_size.x
	var window_heigth = self.rect_size.y
	color_map_y = colormap_box.position.y
	colormap.scale.x = window_width / map_width
	colormap.scale.y = (window_heigth-color_map_y) / map_heigth
	setColorTo(coord_rel.x, coord_rel.y)

func setupColorSelector():
	var img_texture = ImageTexture.new()
	img_texture.create_from_image(color_map_image)
	colormap.texture = img_texture
	setupSize()

func setColorTo(x_rel, y_rel):
	coord_rel.x = x_rel
	coord_rel.y = y_rel
	var max_x = self.rect_size.x - 1
	var max_y = self.rect_size.y - 1 - color_map_y
	var coord: Vector2
	coord.x = int(float(x_rel) / AppearanceManager.COLOR_XY * max_x)
	coord.y = int(float(y_rel) / AppearanceManager.COLOR_XY * max_y)
	cursor.set_position(coord)

func _on_ColorSelector_gui_input(event):
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT:
		_selectColor(event.position)
		if not event.pressed:
			preview_border.hide()
	elif event is InputEventMouseMotion and Input.is_mouse_button_pressed(BUTTON_LEFT):
		_selectColor(event.position)

func _selectColor(coords: Vector2):
	var max_x = self.rect_size.x - 1
	var max_y = self.rect_size.y - 1 - color_map_y
	var colormap_coords: Vector2
	var pixel_color: Color
	var customization: Dictionary = {}
	coords.y -= color_map_y
	
	if coords.x >= 0 and coords.x < max_x and coords.y >= 0 and coords.y < max_y:
		cursor.set_position(coords)
		preview_border.show()
		customization["x"] = int(float(coords.x) / max_x * AppearanceManager.COLOR_XY)
		customization["y"] = int(float(coords.y) / max_y * AppearanceManager.COLOR_XY)
		coord_rel.x = customization["x"]
		coord_rel.y = customization["y"]
		colormap_coords =  coords / 1.0 / colormap.scale
		color_map_image.lock()
		pixel_color = color_map_image.get_pixelv(colormap_coords)
		color_map_image.unlock()
		color_preview.color = pixel_color
		customization["r"] = pixel_color.r
		customization["g"] = pixel_color.g
		customization["b"] = pixel_color.b
		emit_signal("color_changed", customization, my_name)
		if coords.y < max_y - 35:
			preview_border.rect_position.y = 10
		else:
			preview_border.rect_position.y = -40
	else:
		preview_border.hide()


func _on_ColorSelector_resized():
	setupSize()
