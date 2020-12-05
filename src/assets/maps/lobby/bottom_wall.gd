extends YSort

onready var fade_trigger: Area2D = $FadeTrigger
onready var players: YSort = get_tree().get_root().get_node("Main/players")
onready var main_player: KinematicBody2D

const fade_speed: float = 5.0
var fading_in: bool
var fading_out: bool

func _process(delta: float) -> void:
	if fading_in:
		modulate.a += delta * fade_speed
		if modulate.a >= 1.0:
			fading_in = false
	if fading_out:
		modulate.a -= delta * fade_speed
		if modulate.a <= 0.0:
			fading_out = false

func _on_FadeTrigger_body_entered(body: Node) -> void:
	_check_fade(body)

func _on_FadeTrigger_body_exited(body: Node) -> void:
	_check_fade(body)

func _check_fade(body: KinematicBody2D) -> void:
	"""Fade the bottom wall in or out if the main player is moving away from or towards it."""
	if body.is_in_group("players") and body.main_player:
		if body.velocity.y > 0:
			fading_in = false
			fading_out = true
		elif body.velocity.y < 0:
			fading_in = true
			fading_out = false
