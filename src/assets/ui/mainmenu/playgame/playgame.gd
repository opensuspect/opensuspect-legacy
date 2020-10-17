extends Container

func _ready() -> void:
	pass

func _on_Connect_pressed() -> void:
	Network.connection = Network.Connection.CLIENT
	Network.hostName = $JoinGameMenu/HostnameLine/HostnameField.text
	Network.port = $JoinGameMenu/Port/PortField.text
	Network.client()
	Network.playername = "bababooey"
func _on_Create_pressed() -> void:
	Network.connection = Network.Connection.CLIENT_SERVER
	Network.hostName = 'localhost'
	Network.port = $CreateGameMenu/PortLine/PortField.text
	Network.server()
	Network.playername = "themachine"

func _on_JoinGame_pressed() -> void:
	show_only('JoinGameMenu')

func _on_CreateGame_pressed() -> void:
	show_only('CreateGameMenu')

func show_only(element_name) -> void:
	var element: Node = get_node(element_name)
	for child in get_children():
		child.visible = (child == element)

func set_default() -> void:
	show_only('PlayGameMenu')

func _on_Back_pressed():
	if $PlayGameMenu.visible:
		get_node('..').emit_signal("returnToMainMenu")
	else:
		set_default()
