extends KinematicBody2D
class_name Player

onready var death_handler: Node2D = $DeathHandler
onready var infiltrator_scene: PackedScene = load("res://assets/player/infiltrator.tscn")
onready var item_handler: Node2D = $ItemHandler
onready var item_pickup_range: Area2D = $ItemPickupRange
onready var skeleton: Node2D = $Skeleton
onready var animator: AnimationPlayer = skeleton.get_node("AnimationPlayer")
onready var animation_tree: AnimationTree = animator.get_node("AnimationTree")
onready var anim_fsm: AnimationNodeStateMachinePlayback = animation_tree.get("parameters/playback")
onready var item_transform: RemoteTransform2D = skeleton.get_node("Skeleton/Spine/RightUpperArm/RightLowerArm/RightHand/ItemTransform")
onready var sprites_viewport: Viewport = $SpritesViewport

signal main_player_moved(position, velocity, input_number)

export (int) var speed = 150

# Whether the player's controls are frozen
var _movement_disabled: bool setget set_movement_disabled, is_movement_disabled
# Set by main.gd. Is the client's unique id for this player
var id: int
var ourname: String
var myRole: String
var velocity = Vector2(0,0)
# Contains the current intended movement direction and magnitude in range 0 to 1
var movement = Vector2(0,0)
# Only true when this is the player being controlled
export var main_player = false
#anim margin controls how big the player movement must be before animations are played
var x_anim_margin = 0.00
var y_anim_margin = 0.00
#whether the character faces in the right direction
var face_right = true
# The blend between the idle and move animations in the player's animation tree
var idle_move_blend: Vector2

# The input number is incremented on each _physics_process call. GDScript's int
# type is int64_t which is enough for thousands of years of gameplay
var input_number: int = 0
# Contains the last input number that the server has received
var last_received_input: int = 0
# Contains the movement values for unreceived inputs and matching previous
# velocities for movement prediciton. The values are stored as Arrays of
# movement and previous velocity.
var input_queue: Array = []

func _ready():
	# Reparent ItemHandler to Skeleton Node2D
	remove_child(item_handler)
	skeleton.add_child(item_handler)
	skeleton.move_child(item_handler, 6)
	item_transform.remote_path = item_transform.get_path_to(item_handler)

	#print_debug("(player.gd/_ready)")
	# Reparent Skeleton Node2D to SpritesViewport
	remove_child(skeleton)
	sprites_viewport.add_child(skeleton)

	#TEMPORARIALLY DISABLED FOR GLASSES GUY
	if "--server" in OS.get_cmdline_args():
		main_player = false
	if main_player:
		setName(Network.get_player_name())
		id = Network.get_my_id()
	else:
		$MainLight.hide()
		$Camera2D.queue_free()
	#TODO: tell the player node their role upon creation in main.gd
	roles_assigned(PlayerManager.get_player_roles())
# warning-ignore:return_value_discarded
	# connecting this signal causes the player node to receive it during round
	# switching and before the new player nodes are spawned
	# players should probably be deleted in the cleanup phase
#	PlayerManager.connect("roles_assigned", self, "roles_assigned")
	AppearanceManager.connect("apply_appearance", self, "customizePlayer")
	customizePlayer(id)

func _input(event: InputEvent) -> void:
	# Item Handler does not receive input as a child of a Viewport
	item_handler._input(event)

func setName(newName):
	ourname = newName
	$Label.text = ourname

func roles_assigned(playerRoles: Dictionary):
	#print("id: ", id)
	if not playerRoles.keys().has(id):
		return
	myRole = playerRoles[id]
	changeNameColor(myRole)
	_checkRole(myRole)

func _checkRole(role: String) -> void:
	"""Performs certain functions depending on the passed in role parameter."""
	match role:
		"infiltrator":
			set_collision_layer_bit(3, true)
			if not has_node("Infiltrator"):
				add_child(infiltrator_scene.instance())
		"detective":
			if has_node("Infiltrator"):
				get_node("Infiltrator").queue_free()
		"agent":
			set_collision_layer_bit(2, true)
			if has_node("Infiltrator"):
				get_node("Infiltrator").queue_free()

func changeNameColor(role: String):
	match role:
		"infiltrator":
			if PlayerManager.ourrole == "infiltrator":
				setNameColor(PlayerManager.playerColors["infiltrator"])
		"detective":
			#not checking if our role is detective because everyone should see detectives
			setNameColor(PlayerManager.playerColors["detective"])
		"agent":
			setNameColor(PlayerManager.playerColors["agent"])

func setNameColor(newColor: Color):
	$Label.set("custom_colors/font_color", newColor)

func is_movement_disabled() -> bool:
	"""Returns whether player movement is disabled or not."""
	return _movement_disabled

func set_movement_disabled(movement_disabled: bool) -> void:
	"""Set whether player movement should be disabled."""
	_movement_disabled = movement_disabled

# Only called when main_player is true
func get_input():
	movement = Vector2(0, 0)
	if not UIManager.in_ui() and not is_movement_disabled():
		movement.x = Input.get_action_strength('ui_right') - Input.get_action_strength('ui_left')
		movement.y = Input.get_action_strength('ui_down') - Input.get_action_strength('ui_up')
		movement = movement.normalized()

func animate(current_velocity: Vector2) -> void:
	"""
	Set the blend between the idle and move animations in the animation tree's
	root state machine based on the player's current velocity.
	"""
	var blend_position := Vector2(0, current_velocity.length() / speed)
	animation_tree.set("parameters/idle_move_blend/blend_position", blend_position)

func run_physics(motion):
	var prev_velocity = velocity
	velocity = motion * speed
	#interpolate velocity:
	if velocity.x == 0:
		velocity.x = lerp(prev_velocity.x, 0, 0.17)
	if velocity.y == 0:
		velocity.y = lerp(prev_velocity.y, 0, 0.17)
	# TODO: provide a delta value to this function and use it here
	velocity = move_and_slide(velocity)

func customizePlayer(customize_id):
	"""
	Customizes the player's character
	"""
	if id != customize_id:
		return
	var customizationData = AppearanceManager.getPlayerAppearance(id)
	if customizationData != null:
		if self.has_node("SpritesViewport/Skeleton"):
			self.get_node("SpritesViewport/Skeleton").applyCustomization(customizationData)
		elif self.has_node("Skeleton"):
			self.get_node("Skeleton").applyCustomization(customizationData)

func _physics_process(_delta):
	if main_player:
		get_input()
		input_number += 1
		input_queue.push_back([movement, velocity])
		emit_signal("main_player_moved", movement, velocity, input_number)
	# Remove this if check to get bad movement extrapolation for all players
	if main_player or get_tree().is_network_server():
		run_physics(movement)

	# We handle animations and stuff here
	animate(velocity)
	if movement.x > x_anim_margin:
		if not face_right:
			face_right = true
			skeleton.scale.x *= -1
	elif movement.x < -x_anim_margin:
		if face_right:
			face_right = false
			skeleton.scale.x *= -1

# Only called on the main player. Rerolls the player's unreceived inputs on top
# of the server's player position
func _on_positions_updated(new_last_received_input: int):
	if new_last_received_input > input_number:
		# The map has probably changed when this happens
		return
	# Remove received inputs from the queue
	for _i in range(new_last_received_input - last_received_input):
		input_queue.pop_front()
	last_received_input = new_last_received_input
	# Set the initial velocity to predict velocity slowdown correctly
	if input_queue.size() >= 1:
		velocity = input_queue[0][1]
	# Run the physics model for the unreceived inputs
	for i in input_queue:
		run_physics(i[0])

func move_to(new_pos, new_movement):
	position = new_pos
	movement = new_movement

func get_is_alive() -> bool:
	return not death_handler.is_dead
