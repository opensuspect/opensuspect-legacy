extends Node

#this script will sync game events, like round resetting and meetings
var ingame: bool = false
#signal to detect if the game has started; defaults to false
#signals that help sync the gamestate
#can be connected to from anywhere with GameManager.connect("<signal name>", self, "<function name>")
signal resetLobby
signal gamestart
func _ready():
	pass
