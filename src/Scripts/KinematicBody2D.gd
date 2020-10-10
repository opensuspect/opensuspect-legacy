extends KinematicBody2D

export (int) var speed = 200

# Set by main.gd. Is the client's unique id for this player
var id
var velocity = Vector2(0,0)

func get_input():
	var prev_velocity = velocity
	velocity = Vector2(0, 0)
	$Sprite.play("walk")
	if Input.is_action_pressed('ui_right'):
		velocity.x = 1
		$Sprite.flip_h = false
	if Input.is_action_pressed('ui_left'):
		velocity.x = -1
		$Sprite.flip_h = true
	if Input.is_action_pressed('ui_down'):
		velocity.y = 1
	if Input.is_action_pressed('ui_up'):
		velocity.y = -1
	velocity = velocity.normalized() * speed

	#interpolate velocity:
	if velocity.x == 0:
		velocity.x = lerp(prev_velocity.x, 0, 0.17)
	if velocity.y == 0:
		velocity.y = lerp(prev_velocity.y, 0, 0.17)
	if velocity.length() < 50:
		$Sprite.play("idle")

func _physics_process(delta):
	get_input()
	velocity = move_and_slide(velocity)
	
