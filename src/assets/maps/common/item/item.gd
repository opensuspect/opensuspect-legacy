extends RigidBody2D

var pick = false

var texture = "item1"
var prop
var for_tra=Vector2(0, 0)
var mov_speed =0.3

var item0 = preload("res://assets/maps/common/item/icon/item0.png")
var item1 = preload("res://assets/maps/common/item/icon/item1.png")
func _ready():
	texture()
	pass
	
	
func _process(delta):
	if pick == false:
		prop = get_node("Sprite")
		prop.translate(for_tra)
	else:
		pass

func texture():
	if texture == "item0":
		get_node("Sprite").set_texture(item0)

	elif texture == "item1":
		get_node("Sprite").set_texture(item1)

		

func _on_Timer_timeout():
	if for_tra == Vector2(0,-mov_speed):
		for_tra = Vector2(0, mov_speed)
	else:
		for_tra = Vector2(0, -mov_speed)
