extends VBoxContainer

func _ready():
	$Back.connect("pressed", get_node(".."), "_on_Return")

func _on_JoinGame_pressed():
	$JoinGameDialog.popup()

func _on_Connect_pressed():
	Network.connection = Network.Connection.CLIENT
	Network.hostName = $JoinGameDialog/JoinGameOptions/HostnameLine/HostnameField.text
	Network.port = $JoinGameDialog/JoinGameOptions/Port/PortField.text
	Network.client()
	#get_tree().change_scene("res://scenes/main.tscn")

func _on_Create_pressed():
	Network.connection = Network.Connection.CLIENT_SERVER
	Network.hostName = 'localhost'
	Network.port = $CreateGameDialog/CreateGameOptions/PortLine/PortField.text
	Network.server()
	#get_tree().change_scene("res://scenes/main.tscn")

func _on_CreateGame_pressed():
	$CreateGameDialog.popup()
