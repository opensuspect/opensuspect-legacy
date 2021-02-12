tool
extends InteractTask


export var sup: String


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _gen_task_data() -> Dictionary:
	print("clockset gen task data")
	return {}
