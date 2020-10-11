extends KinematicBody2D

export (int) var speed = 200

# Set by main.gd. Is the client's unique id for this player
var id
var velocity = Vector2(0,0)
# Only true when this is the player being controlled
var main_player = true

func _ready():
	if "--server" in OS.get_cmdline_args():
		main_player = false

# Only called when main_player is true
func get_input():
	velocity = Vector2(lerp(velocity.x,0,0.17),lerp(velocity.y,0,0.17))
	#interpolate velocity:
	$Sprite.play("walk")
	var moving = false
	if Input.is_action_pressed('ui_right'):
		velocity.x = speed
		$Sprite.flip_h = false
		moving = true
	if Input.is_action_pressed('ui_left'):
		velocity.x = -speed
		$Sprite.flip_h = true
		moving = true
	if Input.is_action_pressed('ui_down'):
		velocity.y = speed
		moving = true
	if Input.is_action_pressed('ui_up'):
		velocity.y = -speed
		moving = true
	if not moving:
		$Sprite.play("idle")

func _physics_process(delta):
	if main_player:
		$Camera2D.current = true
		get_input()
		velocity = move_and_slide(velocity)
		# Send move rpc to server
		get_node("../").rpc_id(1, "player_moved", position.x, position.y)
	else:
		$Camera2D.current = false
		# We handle animations and stuff here
		pass

func move_to(new_x, new_y):
	# Movement check here
	position.x = new_x
	position.y = new_y
