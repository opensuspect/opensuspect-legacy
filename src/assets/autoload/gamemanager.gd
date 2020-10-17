extends Node

#this script will sync game events, like round resetting and meetings
var ingame: bool = false

#signals that help sync the gamestate
#can be connected to from anywhere with GameManager.connect("<signal name>", self, "<function name>")
signal resetLobby

func _ready():
	pass
