extends Node2D

# The player that the item handler is a child of
onready var player: KinematicBody2D = get_owner()
# The area within which items may be picked up
onready var item_pickup_range: Area2D = player.get_node("ItemPickupRange")

# Emitted when the player picks up an item
signal main_player_picked_up_item(item_path)
# Emitted when the player drops an item
signal main_player_dropped_item(item_path)

# The item that will be picked up if the player decides to do so
var _target_item: KinematicBody2D
# The current item in the player's hand
var picked_up_item: KinematicBody2D

func _ready() -> void:
	player.get_node("DeathHandler").connect("dead", self, "_on_Player_dead")

func _process(delta: float) -> void:
	if player.main_player:
		_get_target()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and not player.is_movement_disabled():
		if get_child_count() > 0:
			emit_signal("main_player_dropped_item")
		if _target_item != null:
			emit_signal("main_player_picked_up_item", _target_item.get_path())

func _get_target() -> void:
	"""Every frame, get the nearest item to the player and highlight it in yellow."""
	var distance: float = INF
	_target_item = null
	for body in item_pickup_range.get_overlapping_bodies():
		if not body.is_in_group("items"):
			continue
		body.material.set_shader_param("line_color", Color.transparent)
		if (body.global_position - player.global_position).length() < distance:
			distance = (body.global_position - player.global_position).length()
			_target_item = body
	if _target_item != null:
		_target_item.material.set_shader_param("line_color", Color.yellow)

func pick_up(item: KinematicBody2D) -> void:
	"""Pick up an item."""
	item.get_parent().remove_child(item)
	add_child(item)
	item.set_collision_layer_bit(4, false)
	item.position = Vector2.ZERO
	if player.has_node("Infiltrator"):
		player.get_node("Infiltrator").enable_killing(false)

func drop(item: KinematicBody2D) -> void:
	"""Drop an item."""
	var map_items: Node2D = MapManager.get_current_map().items
	var offset: Vector2 = player.global_position - map_items.global_position
	remove_child(item)
	map_items.add_child(item)
	item.position = offset
	item.set_collision_layer_bit(4, true)
	if player.has_node("Infiltrator"):
		player.get_node("Infiltrator").enable_killing(true)

func _on_ItemPickupRange_body_exited(body: Node) -> void:
	body.material.set_shader_param("line_color", Color.transparent)
	if len(item_pickup_range.get_overlapping_bodies()) <= 0:
		_target_item = null

func _on_Player_dead() -> void:
	emit_signal("main_player_dropped_item")
