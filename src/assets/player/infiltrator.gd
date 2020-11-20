extends Node2D

# Scene containing UI element for kill indicator
onready var killui_scene: PackedScene = load("res://assets/ui/hud/infiltratorui/killui.tscn")

# UI Controller for the player
onready var ui_controller: CanvasLayer = get_tree().get_root().find_node("uicontroller", true, false)
# Area within which a player may be killed
onready var kill_area: Area2D = $KillArea
# Cooldown before next kill may be made
onready var kill_cooldown_timer: Timer = $KillCooldownTimer
# Parent player
onready var player: KinematicBody2D = get_parent()

# Emitted when the infiltrator kills a player
signal kill(player)

# Whether the infiltrator may kill or not
var _killing_enabled: bool = true setget enable_killing
# The highlighted target if the infiltrator decides to kill
var _target_player: KinematicBody2D

func _ready() -> void:
	if player.main_player:
		_instantiate_kill_gui()

func _process(delta: float) -> void:
	if _killing_enabled and player.main_player:
		_get_target()

func _input(event: InputEvent) -> void:
	if player.main_player:
		if _killing_enabled and event.is_action_pressed("kill") and len(kill_area.get_overlapping_bodies()) > 0:
			_kill_player(_target_player)
		elif event.is_action_pressed("reload"):
			_reload()

func _kill_player(player: KinematicBody2D) -> void:
	"""
	Kill the player who is currently the target.
	"""
	var target_sprite: AnimatedSprite = _target_player.get_node("Sprite")
	target_sprite.material.set_shader_param("line_color", Color.transparent)
	emit_signal("kill", _target_player)
	enable_killing(false)
	kill_cooldown_timer.start()

func _get_target() -> void:
	"""
	Each frame, highlight the nearest target within the kill area in red as the
	player who will be killed if the infiltrator decides to do so.
	"""
	var distance: float = INF
	_target_player = null
	for player in kill_area.get_overlapping_bodies():
		var temp_distance: float = (player.global_position - global_position).length()
		if temp_distance < distance:
			distance = temp_distance
			_target_player = player
	if _target_player != null:
		var target_sprite: AnimatedSprite = _target_player.get_node("Sprite")
		target_sprite.material.set_shader_param("line_color", Color.red)

func _instantiate_kill_gui() -> void:
	"""
	Add kill UI to the infiltrator's HUD
	"""
	var killui: Control = killui_scene.instance()
	killui.infiltrator = self
	killui.rect_position = Vector2(850, 500)
	ui_controller.add_child(killui)

func _reload() -> void:
	"""
	Reload the infiltrator's weapon.
	"""
	# TODO: Play animation for reloading, ideally using an added AnimationPlayer
	#       so that animation_finished signal and anim_name parameter may be used.
	pass

func enable_killing(enable: bool = true) -> void:
	"""
	Enable or disable killing; may be used from outside of script.
	"""
	_killing_enabled = enable

func _on_KillArea_body_exited(body: Node) -> void:
	"""
	Remove the outline from the body that exited the kill area.
	"""
	if player.main_player:
		var sprite: AnimatedSprite = body.get_node("Sprite")
		sprite.material.set_shader_param("line_color", Color.transparent)

func _on_KillCooldownTimer_timeout() -> void:
	"""
	Re-enable killing mechanic after cooldown ends.
	"""
	enable_killing()
