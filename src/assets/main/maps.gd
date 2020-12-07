extends Node2D

const maps_path: String = "res://assets/maps/"

signal spawn(position, frommap)

var current_map: Node

func _ready() -> void:
	set_network_master(1)
	switch_map("lobby")
# warning-ignore:return_value_discarded
	GameManager.connect("state_changed", self, "_on_state_change")

# warning-ignore:unused_argument
func _on_state_change(old_state, new_state) -> void:
	match new_state:
		GameManager.State.Lobby:
			switch_map("lobby")
		GameManager.State.Normal:
			switch_map("test")

func switch_map(new_map_name: String) -> void:
	print("switch_map called for ", new_map_name)
	var map_path: String = Helpers.find_file(new_map_name + ".tscn", maps_path)
	var path_checksum: String = map_path.sha256_text()
	if map_path == "":
		return
	var map_scene: PackedScene = load(map_path)
	print("loading map: ", new_map_name)
	for i in get_children():
		i.queue_free()
	var map_clone = map_scene.instance()
	current_map = map_clone
	add_child(map_clone)
	print("Setting current map")
	MapManager.set_current_map(current_map)
	emit_signal("spawn", get_spawn_points())

func get_spawn_points() -> Array:
	var spawn_point_array: Array = []
	if not get_node(current_map.name + "/SpawnPoints"):
		return [Vector2.ZERO]
	for i in get_node(current_map.name + "/SpawnPoints").get_children():
		spawn_point_array.append(i.global_position)
	#print(spawnPointArray)
	return spawn_point_array
