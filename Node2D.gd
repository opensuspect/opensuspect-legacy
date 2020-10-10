extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	var peer = NetworkedMultiplayerENet.new()
	peer.create_server(7777, 10)
	get_tree().network_peer = peer
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
