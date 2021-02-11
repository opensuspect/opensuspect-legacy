extends Node2D

# The player that this DeathHandler is attached to
onready var player: KinematicBody2D = get_owner()
# The main player (if the player of this DeathHandler is not the main player)
onready var main_player: KinematicBody2D

# the player sprite inside the player scene
onready var player_sprite: Sprite = get_node("../ViewportTextureTarget")
# the light node inside the player scene
onready var player_light: Light2D = get_node_or_null("../MainLight")
# A node that will contain the corpses of players in the current map
onready var corpses: YSort
# Corpse scene that will be instanced when a player dies
onready var corpse_scene: PackedScene = preload("res://assets/player/corpse.tscn")

# Emitted when the player dies
signal dead

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
	emit_signal("dead")
	# disable collisions/enable noclip
	player.collision_mask = 0
	# make the player sprite show on top of walls no matter what, avoids janky y-sorting
	player_sprite.z_index = 100
	# if light node exists, turn off shadows so it goes through walls
	if player_light != null:
		player_light.shadow_enabled = false
	
func create_corpse() -> void:
	"""Create a corpse where the killed player was."""
	var corpse: Node2D = corpse_scene.instance()
	var corpses: Node2D = MapManager.get_current_map().corpses
	var offset: Vector2 = player.global_position + player.get_node("ViewportTextureTarget").position
	corpses.add_child(corpse)
	corpse.position = offset
	var corpse_sprite: Sprite = corpse.get_node("CorpseSprite")
	var image_texture := ImageTexture.new()
	var image: Image = player.get_node("SpritesViewport").get_texture().get_data()
	image_texture.create_from_image(image)
	corpse_sprite.texture = image_texture

func show_ghost() -> void:
	"""Show the player ghost."""
	player.modulate.a = 0.5

func hide_ghost() -> void:
	"""Make the player ghost transparent."""
	player.modulate.a = 0.0

func update_dead_players() -> void:
	"""Either show or hide ghosts depending on whether the player is living or dead."""
	for _player in PlayerManager.players.values():
		var _player_death_handler: Node2D = _player.death_handler
		if _player_death_handler.is_dead:
			if main_player == null:
				main_player = PlayerManager.get_main_player()
			# Show the newly created ghost if the main player is also dead
			if main_player.death_handler.is_dead:
				_player_death_handler.show_ghost()
			# If the player is still alive, then hide the ghost
			else:
				_player_death_handler.hide_ghost()
