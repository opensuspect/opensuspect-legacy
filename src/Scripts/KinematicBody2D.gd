extends KinematicBody2D

export (int) var speed = 500

# Set by main.gd. Is the client's unique id for this player
var id
var velocity = Vector2(0,0)

func get_input():
	velocity = Vector2(lerp(velocity.x,0,0.1),lerp(velocity.y,0,0.1))
	#interpolate velocity:
	if Input.is_action_pressed('ui_right'):
		velocity.x = speed
	if Input.is_action_pressed('ui_left'):
		velocity.x = -speed
	if Input.is_action_pressed('ui_down'):
		velocity.y += speed
	if Input.is_action_pressed('ui_up'):
		velocity.y = -speed
func _physics_process(delta):
	get_input()
	velocity = move_and_slide(velocity)
	
