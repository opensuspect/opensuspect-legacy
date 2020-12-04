extends TextureRect

onready var selector: Control = get_parent()

func _process(delta: float) -> void:
	var selector_size: Vector2 = selector.rect_size
	rect_size = Vector2(selector_size.y, selector_size.x)
	rect_position = Vector2(selector_size.x, 0.0)
