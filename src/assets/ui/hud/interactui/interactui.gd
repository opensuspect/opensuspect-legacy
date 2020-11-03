extends Control

var buttonInteractDict: Dictionary = {}

func _ready():
	createButton("hello testing button creation", "chatbox")

func createButton(interactText, interactWith):
	var newButton = Button.new()
	newButton.name = interactText
	newButton.text = interactText
	buttonInteractDict[interactText] = interactWith
	newButton.connect("pressed", self, "buttonPressed", [newButton.text])
	$HBoxContainer.add_child(newButton)

func buttonPressed(buttonText):
	print(buttonText)
