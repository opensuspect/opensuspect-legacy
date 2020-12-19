extends Node2D
class_name IPoolable

# Base class that pooled object are to derive from and implement.

func spawned() -> void:
	"""Abstract function that is called when the object is spawned."""
	pass

func recycled() -> void:
	"""Abstract function that is called when the object is recycled."""
	pass
