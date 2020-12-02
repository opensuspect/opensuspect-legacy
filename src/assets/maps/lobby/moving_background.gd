extends Node2D

const scroll_reset_threshold: float = 5.0
export (Vector2) var scroll_target := Vector2(-1000, 0)
export (Vector2) var scroll_reset_position := Vector2(1000, 0)
export (float) var scroll_speed := 500.0

func _physics_process(delta: float) -> void:
	position = position.move_toward(scroll_target, scroll_speed * delta)
	if (scroll_target - position).length() <= scroll_reset_threshold:
		position = scroll_reset_position
