extends Node2D

onready var player: KinematicBody2D = get_owner()

# Whether the player is dead
var is_dead: bool = false

func die_by(killer_id: int) -> void:
	"""Player death."""
	is_dead = true
	var killer: KinematicBody2D = PlayerManager.players[killer_id]
	var kill_direction: int = sign(killer.global_position.x - player.global_position.x)
	# Flip the player in the direction of their killer
	if kill_direction < 0 and player.face_right or kill_direction > 0 and not player.face_right:
		player.face_right = not player.face_right
		player.skeleton.scale.x *= -1
	player.set_movement_disabled(true)
	player.anim_fsm.travel("death")
