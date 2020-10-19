extends KinematicBody2D

signal main_player_moved(position)

export (int) var speed = 150

# Set by main.gd. Is the client's unique id for this player
var id
var ourname
var velocity = Vector2(0,0)
# Contains the current intended movement direction and magnitude in range 0 to 1
var movement = Vector2(0,0)
# Only true when this is the player being controlled
var main_player = true
#anim margin controls how big the player movement must be before animations are played
var x_anim_margin = 0.1
var y_anim_margin = 0.1

func _ready():
	if "--server" in OS.get_cmdline_args():
		main_player = false
	if main_player:
		$VisibleArea.enabled = true
		$Dark.enabled = true
		ourname = Network.get_player_name()
	print("ourname: ", ourname)
	$Label.text = ourname
# Only called when main_player is true
func get_input():
	var prev_velocity = velocity
	movement = Vector2(0, 0)
	if not PlayerManager.inMenu:
		movement.x = Input.get_action_strength('ui_right') - Input.get_action_strength('ui_left')
		movement.y = Input.get_action_strength('ui_down') - Input.get_action_strength('ui_up')
		movement = movement.normalized()
		#we did it boys, micheal jackson is no more
#		$Sprite.play("walk-up") for some reason having this makes it not work

	velocity = movement * speed

	#interpolate velocity:
	if velocity.x == 0:
		velocity.x = lerp(prev_velocity.x, 0, 0.17)
	if velocity.y == 0:
		velocity.y = lerp(prev_velocity.y, 0, 0.17)

func _physics_process(delta):
	if main_player:
		get_input()
		velocity = move_and_slide(velocity)
		emit_signal("main_player_moved", position, movement)

	# We handle animations and stuff here
	if movement.x > x_anim_margin:
		$Sprite.play("walk-h")
		$Sprite.flip_h = false
	elif movement.x < -x_anim_margin:
		$Sprite.play("walk-h")
		$Sprite.flip_h = true
	elif movement.y > y_anim_margin:
		$Sprite.play("walk-down")
	elif movement.y < -y_anim_margin:
		$Sprite.play("walk-up")
	else:
		$Sprite.play("idle")

func move_to(new_pos, new_movement):
	# Movement check here
	position = new_pos
	movement = new_movement
