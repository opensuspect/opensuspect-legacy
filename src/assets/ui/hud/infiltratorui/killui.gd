extends Control

# Animator for infiltrator-specific animations
onready var animator: AnimationPlayer
# Infiltrator's kill cooldown timer that will control the appearance of the kill sprite
onready var kill_cooldown_timer: Timer
# Infiltrator node associated with the Kill UI
onready var infiltrator: Node2D
# The sprite that will indicate how much time is left in the reload animation
onready var sprite: AnimatedSprite = $KillSprite

# Loaded with data from call to open_menu function in UIManager
var ui_data: Dictionary = {}

func _ready() -> void:
	if ui_data.keys().has("linked_node"):
		infiltrator = ui_data["linked_node"]
		infiltrator.connect("tree_exited", self, "_on_Infiltrator_tree_exited")
		animator = infiltrator.get_node("Animator")
		kill_cooldown_timer = infiltrator.get_node("KillCooldownTimer")
	if ui_data.keys().has("rect_position"):
		rect_position = ui_data["rect_position"]

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
	sprite.material.set_shader_param("progress", progress)

func base_open() -> void:
	"""
	For sake of compliance with open_menu.
	"""
	pass

func _on_Infiltrator_tree_exited() -> void:
	"""
	Remove the kill icon when infiltrator node is removed from the player.
	"""
	queue_free()
