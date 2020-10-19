extends Node

signal scene_changed

func _ready() -> void:
	GameManager.connect('state_changed', self, '_on_gamestate_change')
	
func _on_gamestate_change(old_state, new_state) -> void:
	if (new_state == GameManager.State.Lobby):
		print("gamestate just changed to Lobby, loading scene...")
		get_tree().change_scene("res://assets/main/main.tscn")
