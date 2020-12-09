extends ControlBase

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
# ui_data var now built into the class
#var ui_data: Dictionary = {}

func _ready() -> void:
	if ui_data.keys().has("linked_node"):
		infiltrator = ui_data["linked_node"]
		infiltrator.connect("kill", self, "_on_Infiltrator_kill")
		infiltrator.connect("stopped_reloading", self, "_on_Infiltrator_stopped_reloading")
		infiltrator.connect("tree_exited", self, "_on_Infiltrator_tree_exited")
		animator = infiltrator.get_node("Animator")
		animator.connect("animation_finished", self, "_on_Infiltrator_Animator_animation_finished")
		kill_cooldown_timer = infiltrator.get_node("KillCooldownTimer")

func _process(_delta: float) -> void:
#	if kill_cooldown_timer != null and not kill_cooldown_timer.is_stopped():
#		var progress: float = (kill_cooldown_timer.wait_time - kill_cooldown_timer.time_left) / kill_cooldown_timer.wait_time
#		sprite.material.set_shader_param("progress", progress)
	if infiltrator == null:
		return
	if infiltrator.is_reloading():
		var progress: float = 0.0
		if animator != null and animator.current_animation == "Reload":
			progress = animator.current_animation_position / animator.current_animation_length
		reload_button.material.set_shader_param("progress", progress)

func _on_Infiltrator_Animator_animation_finished(anim_name: String) -> void:
	"""
	Hide the reload button and show the kill button once the reload animation
	has finished.
	"""
	if anim_name == "Reload":
		reload_button.hide()
		kill_button.show()

func _on_Infiltrator_kill(_emitter: KinematicBody2D, _target_player: KinematicBody2D) -> void:
	"""Disable the kill button once a kill has been executed."""
	kill_button.hide()
	reload_button.show()
	# Set the reload button to be fully visible initially
	reload_button.material.set_shader_param("progress", 1.0)

func _on_Infiltrator_stopped_reloading() -> void:
	"""
	Reset the reload button's progress when the player stops reloading their
	weapon.
	"""
	reload_button.material.set_shader_param("progress", 1.0)

func _on_Infiltrator_tree_exited() -> void:
	"""Remove the infiltrator icons when the infiltrator node is removed from the player."""
	queue_free()

func _on_KillButton_pressed() -> void:
	"""Execute kill input event action when kill button is pressed."""
	Input.action_press("kill")

func _on_ReloadButton_pressed() -> void:
	"""Execute reload input event action when reload button is pressed."""
	Input.action_press("reload")
