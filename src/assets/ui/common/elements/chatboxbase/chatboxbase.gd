extends Control

onready var chatbox = get_node("chatboxText")
onready var textbox = get_node("HBoxContainer/TextEdit")

var defaultColor: String = "white"
var emptyChars: Array = [" ", "	", "\n", "\r", "\r\n"] #chars considered empty (spaces, tabs, etc.)
var breakChars: Array = ["\n", "\r", "\r\n"]
var maxChars: int = 140
var currentText: String = ""
var cursorCoord: Vector2 = Vector2(0,0) #x is line, y is column
var sentSide: String = "right" #side of chatbox sent messages are on
var receivedSide: String = "left" #side of chatbox received messages are on

func _ready():
	set_network_master(1)
# warning-ignore:return_value_discarded
	PlayerManager.connect("message_received", self, "receiveMessage")
# warning-ignore:return_value_discarded
	PlayerManager.connect("message_received_server", self, "receiveMessageServer")
# warning-ignore:return_value_discarded
	PlayerManager.connect("bulk_messages_received", self, "receiveBulkMessages")
	showBulkMessages(PlayerManager.chatbox_cache)

func update() -> void:
	showBulkMessages(PlayerManager.chatbox_cache)

func sendMessage(content, color: String = defaultColor):
	if isEmpty(content) or hasLineBreaks(content):
		return
	if content.length() > maxChars: #if maxChars is raised clientside it can't affect other clients
		return
	PlayerManager.chatbox_cache.append({"sender": Network.get_my_id(), "content": content, "color": color})
	showMessage(Network.get_my_id(), content, color)
	textbox.text = ""
	currentText = ""
	#TODO: switch to getting the color from locally stored data to avoid sending false colors, same with names
	PlayerManager.send_message(content, color)
	#rpc("receiveMessage", Network.myID, content, color)

func receiveBulkMessages(messageArray: Array):
	if get_tree().is_network_server():
		return
	PlayerManager.chatbox_cache = messageArray
	showBulkMessages(messageArray)

func showBulkMessages(messageArray: Array):
	chatbox.bbcode_text = ""
	for i in messageArray:
		showMessage(i.sender, i.content, i.color)

func receiveMessageServer(sender: int, content: String, color: String):
	#add checks here to make sure it's valid (correct color-sender combo, etc.)
#	if sender != get_tree().get_rpc_sender_id():
#		return
	if isEmpty(content):
		return
	var usedContent = processContent(content)
	PlayerManager.send_message_server(sender, usedContent, color)
	#rpc("receiveMessage", sender, usedContent, color)
	showMessage(sender, content, color)

#TODO: switch to getting the color from locally stored data to avoid sending false colors
func receiveMessage(sender: int, content: String, color: String):
	#add checks here to make sure it's valid (correct color-sender combo, etc.)
	if sender == Network.get_my_id():
		return
	PlayerManager.chatbox_cache.append({"sender": sender, "content": content, "color": color})
	showMessage(sender, content, color)

func showMessage(sender, content, color):
	if isEmpty(content):
		return
	content = processContent(content)
	
	if not Network.get_peers().has(sender):
		return
	chatbox.pop()
	var newMessage: String
	var scroller = chatbox.get_v_scroll()
	#if scrolled all the way down, automatically scroll down to show new message
	if scroller.max_value - scroller.page <= scroller.value:
		chatbox.scroll_following = true
	else:
		chatbox.scroll_following = false
	var senderName: String
	var align: String
	if sender == Network.get_my_id():
		senderName = "You"
		align = sentSide
	else:
		senderName = Network.get_player_name(sender)
		align = receivedSide
	if align == "right":
		newMessage = "[right]" + "[color=" + color + "]" + senderName + "[/color][/right]\n[right][color=" + defaultColor + "]" + content + "[/color][/right]\n"
	else:
		newMessage = "[color=" + color + "]" + senderName + "[/color]\n[color=" + defaultColor + "]" + content + "[/color]\n"
	chatbox.append_bbcode(newMessage)

func restrictText():
	var newText: String = textbox.text
	if newText.length() > maxChars or textbox.get_line_count() > 1: #wrapped lines aren't counted
		textbox.text = currentText
		textbox.cursor_set_line(cursorCoord.x)
		textbox.cursor_set_column(cursorCoord.y)
	else:
		currentText = newText

func processContent(content) -> String:
	var usedContent: String = content
	usedContent = removeLineBreaks(usedContent)
	return content

func removeLineBreaks(content: String) -> String:
	var newContent = content
	for i in breakChars:
		newContent = newContent.replace(i, "")
	return newContent

#tests if the string is full of empty chars, like tabs and spaces
func isEmpty(inputStr):
	if inputStr == "":
		return true
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

func focus_textbox():
	textbox.grab_focus()

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

func _on_chatboxbase_visibility_changed():
	if visible:
		textbox.grab_focus()
