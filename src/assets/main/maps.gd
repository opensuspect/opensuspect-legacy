extends Node2D

var maps: Dictionary = {"lobby": {"dir": preload("res://assets/maps/lobby/lobby.tscn")}, "test": {"dir": preload("res://assets/maps/test/test.tscn")}}

signal spawn(position,frommap)

var currentMap: String = "lobby"

func _ready() -> void:
	set_network_master(1)
	switchMap(currentMap)
# warning-ignore:return_value_discarded
	GameManager.connect('state_changed', self, '_on_state_change')

# warning-ignore:unused_argument
func _on_state_change(old_state, new_state) -> void:
	match new_state:
		GameManager.State.Lobby:
			switchMap('lobby')
		GameManager.State.Normal:
			switchMap('test')

func switchMap(newMap: String) -> void:
	print('switchMap called for ', newMap)
	if not maps.keys().has(newMap):
		return
	print("loading map: ", newMap)
	for i in get_children():
		i.queue_free()
	currentMap = newMap
	var mapClone = maps[newMap].dir.instance()
	add_child(mapClone)
	emit_signal("spawn", getSpawnPoints())

func getSpawnPoints() -> Array:
	var spawnPointArray: Array = []
	if not get_node(str(currentMap + "/spawnpoints")):
		return [Vector2(0,0)]
	for i in get_node(str(currentMap + "/spawnpoints")).get_children():
		spawnPointArray.append(i.global_position)
	#print(spawnPointArray)
	return spawnPointArray
