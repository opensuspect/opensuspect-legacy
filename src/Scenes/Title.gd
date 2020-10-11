extends MarginContainer

func _ready():
	if "--server" in OS.get_cmdline_args():
		get_tree().change_scene("res://Scenes/main.tscn")

func _on_NewGame_pressed():
	get_tree().change_scene("res://Scenes/main.tscn")
