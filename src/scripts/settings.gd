extends Control

# Supported nodes
enum SettingType{
	SWITCH
}

# Init config
# This should be in start of game
onready var config = ConfigFile.new()

# Setting class
class Setting:
	var default
	var value
	var text: String
	var type: int
	var function: String
	var config_name: String

	func _init(default, type, text, function, value=null):
		self.default = default
		self.value = value
		self.type = type
		self.text = text
		self.function = function

		# Make this more reliable
		self.config_name = text.to_lower().replace(" ", "_")

		if value == null:
			self.value = default

# Wrapper function to save and update setting
func _save_state(function, node, setting):
	match setting.type:
		SettingType.SWITCH:
			setting.value = node.pressed
			config.set_value("general", setting.config_name, setting.value)

	config.save("user://settings.cfg")
	call(function, setting)

var settings = [
	Setting.new(true, SettingType.SWITCH, tr("Fullscreen"), "toggle_fullscreen"),
	Setting.new(false, SettingType.SWITCH, tr("Colorblind mode"), "toggle_colorblind"),
]

func _ready():
	# Load configuration
	var err = config.load("user://settings.cfg")
	if err != OK:
		raise()
	
	# Init settings view
	var vbox = VBoxContainer.new()
	add_child(vbox)

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
		hbox.add_child(new_label)

		call(setting.function, setting)
		# Add action (Button, CheckBox...)
		match setting.type:
			SettingType.SWITCH:
				var check_button = CheckButton.new()
				check_button.pressed = setting.value
				check_button.connect("pressed", self, "_save_state", [setting.function, check_button, setting])
				hbox.add_child(check_button)

		vbox.add_child(hbox)

func toggle_colorblind(setting):
	# apply shader
	pass

func toggle_fullscreen(setting):
	OS.window_fullscreen = setting.value
