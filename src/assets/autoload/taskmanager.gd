extends Node


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
#more important stuff will probabally be here, later.
signal gentask
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
func spawntask(task2spawn):
	emit_signal("gentask",task2spawn)
