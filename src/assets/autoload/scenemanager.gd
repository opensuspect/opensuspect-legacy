extends Node

signal scene_changed(old_scene, new_scene)

func _ready() -> void:
# warning-ignore:return_value_discarded
	GameManager.connect("state_changed_priority", self, "_on_state_changed_priority")
	
func _on_state_changed_priority(old_state: int, new_state: int, priority: int) -> void:
	if priority != 0:
		return
	if new_state == GameManager.State.Lobby:
		if old_state == GameManager.State.Normal:
			return
		print("(scenemanager.gd/_on_state_changed_priority) gamestate just changed to Lobby, loading scene...")
# warning-ignore:return_value_discarded
		change_scene_manual("res://assets/main/main.tscn")
	if new_state == GameManager.State.Start:
		print("(scenemanager.gd/_on_state_changed_priority) gamestate just changed to Start, loading scene...")
# warning-ignore:return_value_discarded
		change_scene_manual("res://assets/ui/mainmenu/mainmenu.tscn")

func change_scene_manual(new_scene_path: String):
	# unload current scene
	get_tree().get_current_scene().queue_free()
	# instance new scene
	var new_scene = load(new_scene_path).instance()
	# add new scene to tree
	get_tree().get_root().add_child(new_scene)
	# tell the tree that this node is the current scene root
	get_tree().set_current_scene(new_scene)
	print("scene loaded")
