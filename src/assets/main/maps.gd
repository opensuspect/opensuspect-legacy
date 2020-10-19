extends Node2D

var maps: Dictionary = {"lobby": {"dir": preload("res://assets/maps/lobby/lobby.tscn")}, "test": {"dir": preload("res://assets/maps/test/test.tscn")}}

var currentMap: String = "lobby"

func _ready():
	set_network_master(1)
	switchMap(currentMap)

puppet func switchMap(newMap: String):
	#if the func is not remotely called rpc sender id will be 0, if server sent it will be 1, negative should be impossible
	if not get_tree().get_rpc_sender_id() < 2:
		return
	if GameManager.ingame:
		return
	if not maps.keys().has(newMap):
		return
	if get_tree().is_network_server():
		rpc("switchMap", newMap)
	for i in get_children():
		i.queue_free()
	currentMap = newMap
	var mapClone = maps[newMap].dir.instance()
	add_child(mapClone)
