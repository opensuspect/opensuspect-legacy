extends Control

# Infiltrator's kill cooldown timer that will control the appearance of the kill sprite
onready var kill_cooldown_timer: Timer
onready var sprite: AnimatedSprite = $KillSprite

var menuData: Dictionary = {}

func _ready() -> void:
	if menuData.keys().has("linked_node"):
		kill_cooldown_timer = menuData["linked_node"].get_node("KillCooldownTimer")	
	if menuData.keys().has("rect_position"):
		rect_position = menuData["rect_position"]

func _process(_delta: float) -> void:
	if kill_cooldown_timer != null and not kill_cooldown_timer.is_stopped():
		var progress: float = (kill_cooldown_timer.wait_time - kill_cooldown_timer.time_left) / kill_cooldown_timer.wait_time
		sprite.material.set_shader_param("progress", progress)

func base_open() -> void:
	"""
	For sake of compliance with open_menu.
	"""
	pass
