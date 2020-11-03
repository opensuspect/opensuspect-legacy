extends Control

var buttonInteractDict: Dictionary = {}



func _ready():
	UIManager.interactUINode = self
	createButton("hello testing button creation", "chatbox")

func createButton(interactText, interactWith):
	var newButton = Button.new()
	newButton.name = generateName(interactText)
	newButton.text = interactText
	buttonInteractDict[newButton.name] = interactWith
	newButton.connect("pressed", self, "buttonPressed", [newButton.name])
	$HBoxContainer.add_child(newButton)

func generateName(interactText: String):
	if not buttonInteractDict.keys().has(interactText):
		return interactText
	#will not actually count up, but it gets the job done
	return generateName(interactText + "1")

func buttonPressed(buttonName):
	print(buttonName)
	if not buttonInteractDict.keys().has(buttonName):
		return
	match typeof(buttonInteractDict[buttonName]):
		TYPE_STRING:
			#open a UI
			UIManager.open_menu(buttonInteractDict[buttonName])
		TYPE_OBJECT:
			#interact with map object
			MapManager.interact_with(buttonInteractDict[buttonName], self)
