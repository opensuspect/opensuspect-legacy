extends Camera2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_taskmanager_gentask(tusk):
	var taskload = load(tusk)
	var task = taskload.instance()
	add_child(task)
