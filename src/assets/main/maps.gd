extends Node2D

#var maps: Dictionary = {"lobby": {"dir": preload("res://assets/maps/lobby/lobby.tscn")}, "test": {"dir": preload("res://assets/maps/test/test.tscn")}}
var map_info: Dictionary = {}

var map_info_dir: String = "res://assets/maps/mapinfo/"
#const MapInfo = preload("res://assets/maps/mapinfo/mapinforesource/mapinfo.gd")

signal spawn(position,frommap)

var currentMap: String = "lobby"

func _ready() -> void:
	set_network_master(1)
	switchMap(currentMap)
#	print(load_map_info_resources())
#	print(Helpers.get_file_paths_in_dir(map_info_dir))
#	print(gen_map_info())
	update_map_info()
# warning-ignore:return_value_discarded
	GameManager.connect("state_changed_priority", self, "_on_state_changed_priority")

# warning-ignore:unused_argument
func _on_state_changed_priority(old_state: int, new_state: int, priority: int) -> void:
	if priority != 1:
		return
	match new_state:
		GameManager.State.Lobby:
			switchMap("Lobby")
		GameManager.State.Normal:
			switchMap("Test")

func switchMap(newMap: String) -> void:
	print('switchMap called for ', newMap)
	print("map_info: ", map_info)
	if map_info.empty():
		update_map_info()
	print("map_info: ", map_info)
	if not map_info.keys().has(newMap):
		push_error("Attempting to switch to a map that does not exist, the resource could be missing or it was parsed incorrectly.")
		return
	print("loading map: ", newMap)
	for i in get_children():
		i.queue_free()
	currentMap = newMap
	var mapClone = instance_map(newMap)
	add_child(mapClone)
	emit_signal("spawn", getSpawnPoints())

func instance_map(map_name: String) -> Node:
	var map_path: String = map_info[map_name]["scene_path"]
	print(map_path)
	var map_scene: PackedScene = load(map_path)
	var map: Node = map_scene.instance()
	return map

func getSpawnPoints() -> Array:
	var spawnPointArray: Array = []
	if not get_node(str(currentMap + "/spawnpoints")):
		return [Vector2(0,0)]
	for i in get_node(str(currentMap + "/spawnpoints")).get_children():
		spawnPointArray.append(i.global_position)
	#print(spawnPointArray)
	return spawnPointArray

func update_map_info() -> void:
	map_info = gen_map_info()

func gen_map_info() -> Dictionary:
	var resources: Array = load_map_info_resources()
	var new_map_info: Dictionary = {}
	for res in resources:
		var dict: Dictionary = {}
		var res_name: String = res.get_name()
		# including name inside nested dict to make it easier if we want for loops later
		for property in ["name", "desc", "thumbnail", "scene_path"]:
			dict[property] = res.get(property)
		dict["res"] = res
		new_map_info[res_name] = dict
	return new_map_info

func load_map_info_resources() -> Array:
	var resources: Array = Helpers.load_files_in_dir_with_exts(map_info_dir, [".tres", ".res"])
	for res in resources:
		if not res is MapInfo:
			resources.erase(res)
	return resources
