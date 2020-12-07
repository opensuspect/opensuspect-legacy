extends ControlBase

var buttonInteractDict: Dictionary = {}

func _ready():
	UIManager.interact_ui_node = self
	#createButton("hello testing button creation", "chatbox")

func receiveInteractData(interactData: Dictionary):
	#print(interactData)
	buttonInteractDict = interactData
	for i in $HBoxContainer.get_children():
		i.queue_free()
	for i in buttonInteractDict.keys():
		createButton(i)

func createButton(interactKey):
	#print(buttonInteractDict)
	var newButton = Button.new()
	newButton.name = interactKey
	#print(newButton.name)
	newButton.text = buttonInteractDict[interactKey].display_text
	newButton.connect("pressed", self, "buttonPressed", [newButton.name])
	$HBoxContainer.add_child(newButton)

func buttonPressed(buttonName):
	#print(buttonName)
	if not buttonInteractDict.keys().has(buttonName):
		return
	buttonInteractDict[buttonName].interact_node.interact()
#	match typeof(buttonInteractDict[buttonName].interact):
#		TYPE_STRING:
#			#open a UI
#			UIManager.open_menu(buttonInteractDict[buttonName].interact)
#		TYPE_OBJECT:
#			#interact with map object
#			MapManager.interact_with(buttonInteractDict[buttonName].interact, self)
