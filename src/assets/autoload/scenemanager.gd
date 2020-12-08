extends Node

# warning-ignore:unused_signal
signal scene_changed #TODO: actually emit this signal

func _ready() -> void:
# warning-ignore:return_value_discarded
	GameManager.connect("state_changed_priority", self, "_on_state_changed_priority")
	
func _on_state_changed_priority(old_state: int, new_state: int, priority: int) -> void:
	if priority != 0:
		return
	if new_state == GameManager.State.Lobby:
		if old_state == GameManager.State.Normal:
			return
		print("gamestate just changed to Lobby, loading scene...")
# warning-ignore:return_value_discarded
		get_tree().change_scene("res://assets/main/main.tscn")
	if new_state == GameManager.State.Start:
		print("gamestate just changed to Start, loading scene...")
# warning-ignore:return_value_discarded
		get_tree().change_scene("res://assets/ui/mainmenu/mainmenu.tscn")
