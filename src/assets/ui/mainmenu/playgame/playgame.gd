extends Container

func _ready() -> void:
	pass

func _on_Connect_pressed() -> void:
	var hostName: String = $JoinGameMenu/HostnameLine/HostnameField.text
	var port: int = $JoinGameMenu/Port/PortField.text as int
	var playerName: String = $JoinGameMenu/Name/NameField.text
	Network.client(hostName, port, playerName)

func _on_Create_pressed() -> void:
	var port: int = $CreateGameMenu/PortLine/PortField.text as int
	var playerName: String = $CreateGameMenu/Name/NameField.text
	Network.client_server(port, playerName)

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
