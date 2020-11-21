extends GridContainer

# @todo design team: change colors
const COLORS = [
	"#ffffff",
	"#aaaaaa",
	"#555555",
	"#000000",
	"#4b0f37",
	"#9f1d2e",
	"#df5f36",
	"#f0a34a",
	"#f0cc69",
	"#beb866",
	"#819650",
	"#497a3a",
	"#094d18",
	"#227944",
	"#449481",
	"#63b9bb",
	"#8cdaff",
	"#7294d6",
	"#5959b3",
	"#5b2b7c"
]

signal color_change
export var selectedColor : Color setget update_color


func _ready():
	for color in COLORS:
		var swatch = Button.new()
		swatch.flat = true
		swatch.rect_min_size = Vector2(64, 64)
		swatch.toggle_mode = false
		
		var colorRect = ColorRect.new()
		colorRect.rect_size = Vector2(swatch.rect_min_size.x - 2, swatch.rect_min_size.y - 2)
		colorRect.margin_top = 2
		colorRect.margin_left = 2
		colorRect.color = Color(color)
		colorRect.focus_mode = Control.FOCUS_CLICK
		colorRect.connect("focus_entered", self, "_on_color_selected", [swatch])
		colorRect.connect("mouse_entered", self, "_on_swatch_hover", [swatch])
		colorRect.connect("mouse_exited", self, "_on_swatch_hover_end", [swatch])
		
		swatch.add_child(colorRect)
		self.add_child(swatch)
	
	self.selectedColor = Color(COLORS[0])


func _on_color_selected(swatch : Button):
	var color : Color = swatch.get_child(0).color
	self.selectedColor = color
	emit_signal("color_change", color)


func _on_swatch_hover(swatch : Button):
	if swatch.toggle_mode == false:
		swatch.flat = false


func _on_swatch_hover_end(swatch : Button):
	if swatch.toggle_mode == false:
		swatch.flat = true


func update_color(color : Color):
	for swatch in self.get_children():
		if swatch.get_child(0).color == color:
			swatch.toggle_mode = true
			swatch.flat = false
		else:
			swatch.toggle_mode = false
			swatch.flat = true
