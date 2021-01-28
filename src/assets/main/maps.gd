extends Node2D

#var maps: Dictionary = {"lobby": {"dir": preload("res://assets/maps/lobby/lobby.tscn")}, "test": {"dir": preload("res://assets/maps/test/test.tscn")}}
var map_info: Dictionary = {}

var map_info_dir: String = "res://assets/maps/mapinfo/"


signal spawn(position, frommap)

var currentMap: String = "Lobby"


# TODO
# decouple main.gd from map loading
# _ready() is actually called after the transition completes, which means we have to
# either connect to the signal earlier, like in _init(), or edit the scene loading
# process. Currently, connecting in _init() causes a crash in _on_maps_spawned() in
# main.gd. This forces us to switch to a preset map in _ready() and break consistency.
# The better solution would be editing the scene loading process to make sure the scene
# is properly added to the scene tree before GameManager continues emitting signals.
# I'm not sure how to do this, I'm pretty sure reading up on yield woud be helpful
func _ready() -> void:
#	print_debug("(maps.gd/_ready)")
	set_network_master(1)
#	switchMap(currentMap)
	update_map_info()
# warning-ignore:return_value_discarded
	GameManager.connect("state_changed_priority", self, "_on_state_changed_priority")

#func _init():
# warning-ignore:return_value_discarded
#	GameManager.connect("state_changed_priority", self, "_on_state_changed_priority")

# warning-ignore:unused_argument
func _on_state_changed_priority(old_state: int, new_state: int, priority: int) -> void:
	if priority != 1:
		return
	print("(maps.gd/_on_state_changed_priority)")
	match new_state:
		GameManager.State.Lobby:
			switchMap("Lobby")
		GameManager.State.Normal:
			switchMap("Test")

func switchMap(newMap: String) -> void:
	print("(maps.gd/switchMap) switching to map ", newMap)
#	print("map_info: ", map_info)
	if map_info.empty():
		update_map_info()
	if not map_info.keys().has(newMap):
#		print("Attempting to switch to a map that does not exist, the resource could be missing or it was parsed incorrectly.")
		push_error("Attempting to switch to a map that does not exist, the resource could be missing or it was parsed incorrectly.")
		return
	print("loading map: ", newMap)
	for i in get_children():
		i.queue_free()
	currentMap = newMap
	var mapClone: Node = instance_map(newMap)
	# consistent name makes it easier to get spawnpoints, we should really be 
	# storing the map root node itself, that would come as a larger overhaul to
	# the map system, when we start giving each map it's own script/make a map class.
	mapClone.name = newMap
	add_child(mapClone)
	# the actual map to be used should be in position 0 under the "map" node, and
	# the actual removal of the previous map's node under the "map" node is not
	# soon enough for the item handling to work properly, so we have to put the
	# actual current map to position 0 manually.
	move_child(mapClone, 0)
	emit_signal("spawn", getSpawnPoints())

func instance_map(map_name: String) -> Node:
#	print("instancing map ", map_name)
	var map_path: String = map_info[map_name]["scene_path"]
	var map_scene: PackedScene = load(map_path)
	var map: Node = map_scene.instance()
	return map

func getSpawnPoints() -> Array:
	var spawnPointArray: Array = []
	if not get_node(str(currentMap + "/SpawnPoints")):
		return [Vector2(0,0)]
	for i in get_node(str(currentMap + "/SpawnPoints")).get_children():
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
