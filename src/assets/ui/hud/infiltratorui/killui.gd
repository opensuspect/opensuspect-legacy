extends Control

# Animator for infiltrator-specific animations
onready var animator: AnimationPlayer
# Infiltrator's kill cooldown timer that will control the appearance of the kill sprite
onready var kill_cooldown_timer: Timer
# Infiltrator node associated with the Kill UI
onready var infiltrator: Node2D
# The sprite that will indicate how much time is left in the reload animation
onready var sprite: AnimatedSprite = $KillSprite
# The node responsible for instancing, opening, and closing this GUI
onready var ui_controller: CanvasLayer = get_tree().get_root().find_node("uicontroller", true, false) 

# Loaded with data from call to open_menu function in UIManager
var menuData: Dictionary = {}

func _ready() -> void:
	if menuData.keys().has("linked_node"):
		infiltrator = menuData["linked_node"]
		animator = infiltrator.get_node("Animator")
		kill_cooldown_timer = infiltrator.get_node("KillCooldownTimer")
	if menuData.keys().has("rect_position"):
		rect_position = menuData["rect_position"]

func _process(_delta: float) -> void:
#	if kill_cooldown_timer != null and not kill_cooldown_timer.is_stopped():
#		var progress: float = (kill_cooldown_timer.wait_time - kill_cooldown_timer.time_left) / kill_cooldown_timer.wait_time
#		sprite.material.set_shader_param("progress", progress)
	var progress: float = 0.0
	if animator != null and animator.current_animation == "Reload":
		progress = animator.current_animation_position / animator.current_animation_length
	elif infiltrator != null:
		if not infiltrator.is_reloaded():
			progress = 0.0
		elif infiltrator.is_reloaded():
			progress = 1.0
	elif infiltrator == null:
		queue_free()
	sprite.material.set_shader_param("progress", progress)

func base_close() -> void:
	"""
	For sake of compliance with close_menu.
	"""
	pass

func base_open() -> void:
	"""
	For sake of compliance with open_menu.
	"""
	pass

func close() -> void:
	hide()

func open() -> void:
	show()
