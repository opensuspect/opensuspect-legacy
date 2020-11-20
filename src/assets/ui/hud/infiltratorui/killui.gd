extends Control

# Infiltrator instance that the UI will be connected to
onready var infiltrator: Node2D
# Infiltrator's kill cooldown timer that will control the appearance of the kill sprite
onready var kill_cooldown_timer: Timer = infiltrator.get_node("KillCooldownTimer")
onready var sprite: AnimatedSprite = $KillSprite

func _process(_delta: float) -> void:
	if kill_cooldown_timer != null and not kill_cooldown_timer.is_stopped():
		var progress: float = (kill_cooldown_timer.wait_time - kill_cooldown_timer.time_left) / kill_cooldown_timer.wait_time
		sprite.material.set_shader_param("progress", progress)
