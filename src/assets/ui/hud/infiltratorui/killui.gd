extends Control

# Animator for infiltrator-specific animations
onready var animator: AnimationPlayer
# Infiltrator's kill cooldown timer that will control the appearance of the kill sprite
onready var kill_cooldown_timer: Timer
# Infiltrator node associated with the Kill UI
onready var infiltrator: Node2D
# The texture button that is used to kill another player
onready var kill_button: TextureButton = $KillButton
# The texture button that will indicate how much time is left in the reload animation
onready var reload_button: TextureButton = $ReloadButton

# Loaded with data from call to open_menu function in UIManager
var menuData: Dictionary = {}

func _ready() -> void:
	if menuData.keys().has("linked_node"):
		infiltrator = menuData["linked_node"]
		infiltrator.connect("kill", self, "_on_Infiltrator_kill")
		infiltrator.connect("tree_exited", self, "_on_Infiltrator_tree_exited")
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
			# Re-enable the kill button once the infiltrator has finished reloading.
			kill_button.disabled = false
			progress = 1.0
	reload_button.material.set_shader_param("progress", progress)

func base_open() -> void:
	"""
	For sake of compliance with open_menu.
	"""
	pass

func _on_Infiltrator_kill(_target_player: KinematicBody2D) -> void:
	"""
	Disable the kill button once a kill has been executed.
	"""
	kill_button.disabled = true

func _on_Infiltrator_tree_exited() -> void:
	"""
	Remove the infiltrator icons when the infiltrator node is removed from the player.
	"""
	queue_free()

func _on_KillButton_pressed() -> void:
	"""
	Execute kill input event action when kill button is pressed.
	"""
	Input.action_press("kill")

func _on_ReloadButton_pressed() -> void:
	"""
	Execute reload input event action when reload button is pressed.
	"""
	Input.action_press("reload")
