extends YSort

onready var players: YSort = get_tree().get_root().get_node("Main/players")

func _ready() -> void:
	call_deferred("_disable_player_light")

func _disable_player_light() -> void:
	for player in players.get_children():
		if player.main_player:
			player.get_node("MainLight").visible = false
