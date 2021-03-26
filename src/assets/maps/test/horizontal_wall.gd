extends StaticBody2D
class_name HorizWall

onready var wall_sprite = $Sprite
onready var light_occluder = $LightOccluder2D

const fade_speed: float = 5.0
var fading_in: bool
var fading_out: bool
var occluder_height: float

func _ready():
	occluder_height = light_occluder.position.y

func _process(delta: float) -> void:
	if fading_in:
		wall_sprite.modulate.a += delta * fade_speed
		light_occluder.position.y += delta * fade_speed * occluder_height
		if wall_sprite.modulate.a >= 1.0:
			light_occluder.position.y = occluder_height
			fading_in = false
	if fading_out:
		wall_sprite.modulate.a -= delta * fade_speed
		light_occluder.position.y -= delta * fade_speed * occluder_height
		if wall_sprite.modulate.a <= 0.0:
			light_occluder.position.y = 0
			fading_out = false

func _on_FadeTrigger_body_entered(body: Node) -> void:
	_check_fade(body, true)

func _on_FadeTrigger_body_exited(body: Node) -> void:
	_check_fade(body, false)

func _check_fade(body: KinematicBody2D, entered: bool) -> void:
	"""Fade the bottom wall in or out if the main player is moving away from or towards it."""
	if body.is_in_group("players") and body.main_player:
		if entered:
			fading_in = false
			fading_out = true
		else:
			fading_in = true
			fading_out = false
