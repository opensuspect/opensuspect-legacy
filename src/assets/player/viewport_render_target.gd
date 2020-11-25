extends Sprite


func _ready() -> void:
	# Duplicate the material so that all players are not affected by shader parameter changes.
	material = material.duplicate()
