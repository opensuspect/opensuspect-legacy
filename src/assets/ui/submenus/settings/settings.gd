extends Control

const SLIDER_SIZE = 100

# Node to put settings
export var scroll_cont: NodePath

# Supported nodes
enum SettingType { SWITCH, OPTION, SLIDER }

# Init config
onready var config = ConfigFile.new()

# Setting class
class Setting:
	var default
	var value
	var text: String
	var type: int
	var function: String
	var config_name: String
	var available: Array

	func _init(default, type, text, function, available = null):
		self.default = default
		self.value = default
		self.type = type
		self.text = text
		self.function = function

		if type == SettingType.OPTION:
			self.available = available

		# Make this more reliable
		self.config_name = text.to_lower().replace(" ", "_")


# Wrapper function to save and update setting
func _save_state(value, node, setting):
	if setting.type == SettingType.SWITCH:
		value = node.pressed
	
	setting.value = value
	config.set_value("general", setting.config_name, setting.value)

	config.save("user://settings.cfg")
	call(setting.function, setting)


func dummy_function(setting):
	pass


var settings = [
	Setting.new(true, SettingType.SWITCH, tr("Fullscreen"), "toggle_fullscreen"),
	Setting.new(
		0, SettingType.OPTION, tr("Colorblind mode"), "dummy_function", ["RGB", "GBR", "BRG", "BGR"]
	),
	Setting.new(30, SettingType.SLIDER, tr("Sound"), "dummy_function"),
]


func _ready():
	# Load configuration
	var err = config.load("user://settings.cfg")
	if err != OK:
		raise()

	# Init back button
	var back_button = Button.new()
	back_button.text = "Back"
	back_button.connect("pressed", get_node(".."), "_on_Return")

	# Init settings view
	var vbox = $Settings/VBoxContainer

	# Mapping settings
	for setting in settings:
		if config.has_section_key("general", setting.config_name):
			setting.value = config.get_value("general", setting.config_name)
		else:
			config.set_value("general", setting.config_name, setting.value)

		# Init row
		var hbox = HBoxContainer.new()

		# Init label with text
		var new_label = Label.new()
		new_label.text = setting.text
		new_label.size_flags_horizontal = Control.SIZE_EXPAND
		new_label.align = Label.ALIGN_CENTER
		hbox.add_child(new_label)

		call(setting.function, setting)

		# Add action (Button, CheckBox...)
		match setting.type:
			SettingType.SWITCH:
				var check_button = CheckButton.new()
				check_button.pressed = setting.value
				check_button.connect("pressed", self, "_save_state", [null, check_button, setting])
				hbox.add_child(check_button)

			SettingType.OPTION:
				var option_button = OptionButton.new()
				option_button.connect(
					"item_selected", self, "_save_state", [option_button, setting]
				)
				for option in setting.available:
					option_button.add_item(str(option))

				option_button.select(setting.value)
				hbox.add_child(option_button)

			SettingType.SLIDER:
				var slider = HSlider.new()
				slider.connect("value_changed", self, "_save_state", [slider, setting])
				slider.value = setting.value
				slider.set_h_size_flags(SIZE_EXPAND_FILL)
				hbox.add_child(slider)

		vbox.add_child(hbox)
	vbox.add_child(back_button)


func toggle_fullscreen(setting):
	OS.window_fullscreen = setting.value
