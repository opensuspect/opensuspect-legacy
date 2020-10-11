extends KinematicBody2D

signal main_player_moved(position)

export (int) var speed = 150

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
	var prev_velocity = velocity
	velocity = Vector2(0, 0)
	if Input.is_action_pressed('ui_right'):
		velocity.x = 1
		$Sprite.flip_h = false
		$Sprite.play("walk-h")
	if Input.is_action_pressed('ui_left'):
		velocity.x = -1
		$Sprite.flip_h = true
		$Sprite.play("walk-h")
	if Input.is_action_pressed('ui_down'):
		velocity.y = 1
		$Sprite.play("walk-down")
	if Input.is_action_pressed('ui_up'):
		velocity.y = -1
		$Sprite.play("walk-down")
	velocity = velocity.normalized() * speed

	#interpolate velocity:
	if velocity.x == 0:
		velocity.x = lerp(prev_velocity.x, 0, 0.17)
	if velocity.y == 0:
		velocity.y = lerp(prev_velocity.y, 0, 0.17)
	if velocity.length() < 50:
		$Sprite.play("idle")

func _physics_process(delta):
	if main_player:
		$Camera2D.current = true
		get_input()
		velocity = move_and_slide(velocity)
		emit_signal("main_player_moved", position)
	else:
		$Camera2D.current = false
		# We handle animations and stuff here
		pass

func move_to(new_x, new_y):
	# Movement check here
	position.x = new_x
	position.y = new_y
