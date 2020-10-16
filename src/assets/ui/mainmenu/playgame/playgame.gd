extends VBoxContainer

func _ready():
	$Back.connect("pressed", get_node(".."), "_on_Return")

func _on_JoinGame_pressed():
	$JoinGameDialog.popup()

func _on_Connect_pressed():
	Network.client($JoinGameDialog/JoinGameOptions/HostnameLine/HostnameField.text, $JoinGameDialog/JoinGameOptions/Port/PortField.text as int)

func _on_Create_pressed():
	Network.client_server($CreateGameDialog/CreateGameOptions/PortLine/PortField.text as int)

func _on_CreateGame_pressed():
	$CreateGameDialog.popup()
