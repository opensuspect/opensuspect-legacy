extends CanvasLayer

onready var config = ConfigFile.new()

func _ready():
	set_network_master(1)
	var err = config.load("user://settings.cfg")
	if err == OK:
		$ColorblindRect.material.set_shader_param("mode", int(config.get_value("general", "colorblind_mode")))
