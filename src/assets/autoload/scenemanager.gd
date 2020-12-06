extends Node

signal scene_changed(old_scene, new_scene)

const scene_path: String = "res://assets/maps/"

func _ready() -> void:
# warning-ignore:return_value_discarded
	GameManager.connect('state_changed', self, '_on_gamestate_change')
	
func _on_gamestate_change(old_state, new_state) -> void:
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

func change_scene(new_scene_name: String) -> void:
	var old_scene: Node = get_tree().get_current_scene()
	get_tree().change_scene(scene_path + new_scene_name)
	var new_scene: Node = get_tree().get_current_scene()
	emit_signal("scene_changed", old_scene, new_scene)
