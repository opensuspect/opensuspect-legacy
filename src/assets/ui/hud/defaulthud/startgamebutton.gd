extends Button
# warning-ignore:unused_signal
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
	print("game start triggered")
	# TODO: Looser coupling here would be nice
	if GameManager.get_state() == GameManager.State.Lobby:
# warning-ignore:return_value_discarded
		GameManager.transition(GameManager.State.Normal)
		text = "Back to Lobby"
		Dlman.distribute()
	else:
# warning-ignore:return_value_discarded
		GameManager.transition(GameManager.State.Lobby)
		text = "Start Game"
	#queue_free()
