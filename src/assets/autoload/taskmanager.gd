extends Node

enum task_type {BINARY, ITEM_OUTPUT, ITEM_INPUT}

var tasks: Array = []

func _ready():
	print(task_type.BINARY)
