extends Button
signal gamestartpressed

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	if not Network.connection == Network.Connection.CLIENT_SERVER:
		queue_free()



# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
func _pressed():
	emit_signal("gamestartpressed")
	queue_free()
