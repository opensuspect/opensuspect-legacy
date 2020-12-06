extends RigidBody2D

var pick = false
var prop
var for_tra=Vector2(0, 0)
var mov_speed =0.3

func _ready():
	pass 

func _process(delta):
	if pick == false:
		prop = get_node("Sprite")
		prop.translate(for_tra)
	else:
		return
		

func texture(texture:String):
	#TODO:Set texture for item
	var to_set = load(texture)
	get_node("Sprite").set_texture(to_set)

func _on_Timer_timeout():
	if for_tra == Vector2(0,-mov_speed):
		for_tra = Vector2(0, mov_speed)
	else:
		for_tra = Vector2(0, -mov_speed)

