extends Node2D

var maps: Dictionary = {"test": preload("res://assets/maps/test/test.tscn")}

var currentMap: String = "test"

func _ready():
	switchMap("test")

func switchMap(newMap: String):
	if GameManager.ingame:
		return
	if not maps.keys().has(newMap):
		return
	for i in get_children():
		i.queue_free()
	currentMap = newMap
	var mapClone = maps[newMap].instance()
	add_child(mapClone)
