extends Node2D

onready var player: KinematicBody2D = get_owner()
onready var corpses: YSort
onready var corpse_scene: PackedScene = preload("res://assets/player/corpse.tscn")

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
	player.animator.play("death")
	player.anim_fsm.travel("death")

func create_corpse() -> void:
	var corpse: Node2D = corpse_scene.instance()
	corpses = get_tree().get_root().get_node("Main/maps").get_child(0).get_node("Corpses")
	var offset: Vector2 = player.global_position + player.get_node("ViewportTextureTarget").position
	corpses.add_child(corpse)
	corpse.position = offset
	var corpse_sprite: Sprite = corpse.get_node("CorpseSprite")
	var image_texture := ImageTexture.new()
	var image: Image = player.get_node("SpritesViewport").get_texture().get_data()
	image_texture.create_from_image(image)
	corpse_sprite.texture = image_texture

func turn_into_ghost() -> void:
	player.modulate.a = 0.5

func _on_AnimationPlayer_animation_finished(anim_name: String) -> void:
	if anim_name == "death":
		create_corpse()
		if player.main_player:
			turn_into_ghost()
			player.animator.play("resurrect")
		else:
			player.modulate.a = 0.0
	elif anim_name == "resurrect":
		player.set_movement_disabled(false)
