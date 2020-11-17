extends WindowDialogBase

onready var chatbox = get_node("Control/chatboxText")
onready var textbox = get_node("Control/HBoxContainer/TextEdit")

var defaultColor: String = "white"
var emptyChars: Array = [" ", "	", "\n", "\r", "\r\n"] #chars considered empty (spaces, tabs, etc.)
var breakChars: Array = ["\n", "\r", "\r\n"]
var maxChars: int = 140
var currentText: String = ""
var cursorCoord: Vector2 = Vector2(0,0) #x is line, y is column
var sentSide: String = "right" #side of chatbox sent messages are on
var receivedSide: String = "left" #side of chatbox received messages are on

func open():
	
	textbox.grab_focus()

func sendMessage(content, color: String = defaultColor):
	if isEmpty(content) or hasLineBreaks(content):
		return
	if content.length() > maxChars: #if maxChars is raised clientside it can't affect other clients
		return
	showMessage("You", content, color, sentSide)
	textbox.text = ""
	currentText = ""
	#TODO: switch to getting the color from locally stored data to avoid sending false colors, same with names
	rpc("receiveMessage", Network.myID, content, color, Network.get_player_name())

#TODO: switch to getting the color from locally stored data to avoid sending false colors, same with names
remote func receiveMessage(sender: int, content: String, color: String, sentname: String):
	#add checks here to make sure it's valid (correct color-sender combo, etc.)
	if sender != get_tree().get_rpc_sender_id():
		#having the sender be sent and then checked allows to double check if get_rpc_sender_id returns the wrong id, most likely won't happen as long as we stay single threaded
		pass
	if isEmpty(content) or hasLineBreaks(content):
		return
	#eventually use id to find the player's name
	showMessage(str(sentname), content, color, receivedSide)

func showMessage(sender, content, color, align: String = ""):
	if sender == "" or content == "":
		return
	chatbox.pop()
	var newMessage: String
	var scroller = chatbox.get_v_scroll()
	#if scrolled all the way down, automatically scroll down to show new message
	if scroller.max_value - scroller.page <= scroller.value:
		chatbox.scroll_following = true
	else:
		chatbox.scroll_following = false
	if align == "right":
		newMessage = "[right]" + "[color=" + color + "]" + sender + "[/color][/right]\n[right][color=" + defaultColor + "]" + content + "[/color][/right]\n"
	else:
		newMessage = "[color=" + color + "]" + sender + "[/color]\n[color=" + defaultColor + "]" + content + "[/color]\n"
	chatbox.append_bbcode(newMessage)

func restrictText():
	var newText: String = textbox.text
	if newText.length() > maxChars or textbox.get_line_count() > 1: #wrapped lines aren't counted
		textbox.text = currentText
		textbox.cursor_set_line(cursorCoord.x)
		textbox.cursor_set_column(cursorCoord.y)
	else:
		currentText = newText

#tests if the string is full of empty chars, like tabs and spaces
func isEmpty(inputStr):
	var emptyCount = 0
	for i in emptyChars:
		emptyCount += inputStr.count(i)
	return inputStr.length() == emptyCount

func hasLineBreaks(inputStr):
	pass
	for i in breakChars:
		if inputStr.count(i) != inputStr.count("\\" + i):
			return true
	return false

func _on_send_pressed():
	sendMessage(textbox.text, "green")

func _on_TextEdit_text_changed():
	if textbox.get_line_count() > 1:
		restrictText()
		sendMessage(textbox.text, "green")
		return
	restrictText()

func _on_TextEdit_cursor_changed():
	textbox.center_viewport_to_cursor()
	cursorCoord.x = textbox.cursor_get_line()
	cursorCoord.y = textbox.cursor_get_column()

func _on_chatbox_about_to_show():
	pass

func _on_chatbox_popup_hide():
	pass
