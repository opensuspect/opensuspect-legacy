extends MarginContainer

func _ready():
	_on_Return()

func _on_NewGame_pressed():
	get_tree().change_scene("res://Scenes/main.tscn")


func _on_Settings_pressed():
	get_node("MenuItems").visible = false
	get_node("Settings").visible = true

func _on_Return():
	get_node("Settings").visible = false
	get_node("LanguageSelector").visible = false
	get_node("MenuItems").visible = true
