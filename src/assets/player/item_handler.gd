extends Node2D
class_name ItemHandler

# The player that the item handler is a child of
onready var player: Player = get_owner()
# The area within which items may be picked up
onready var item_pickup_range: Area2D = player.get_node("ItemPickupRange")

# Emitted when the player picks up an item
signal main_player_picked_up_item(item_path)
# Emitted when the player drops an item
signal main_player_dropped_item(item_path)

const item_pickup_mouse_threshold: float = 50.0

# The item that will be picked up if the player decides to do so
var _target_item: Item
# The current item in the player's hand
var picked_up_item: Item

func _ready() -> void:
	player.get_node("DeathHandler").connect("dead", self, "_on_Player_dead")

func _process(delta: float) -> void:
	if player.main_player:
		pass
#		_get_target()

func _input(event: InputEvent) -> void:
	if player.is_movement_disabled():
		return
	if event.is_action_pressed("interact"):
		_get_target()
		_test_pickup(_target_item)
	elif event is InputEventMouseButton and event.pressed and event.button_index == BUTTON_LEFT:
		for body in item_pickup_range.get_overlapping_bodies():
			if body.is_in_group("items") and body.can_pickup_with_mouse:
				_test_pickup(body)
				# Avoid picking up multiple objects at once if they're overlapping
				return

func _exit_tree() -> void:
	# Drop the player's item when a player node is destroyed, e.g. when they disconnect
	emit_signal("main_player_dropped_item")

func _get_target() -> void:
	"""Every frame, get the nearest item to the player and highlight it in yellow."""
	var distance: float = INF
	_target_item = null
	for body in item_pickup_range.get_overlapping_bodies():
		if not body.is_in_group("items"):
			continue
		body.get_node("SpritePosition/ItemSprite").material.set_shader_param("line_color", Color.transparent)
		if (body.global_position - player.global_position).length() < distance:
			distance = (body.global_position - player.global_position).length()
			_target_item = body
	if _target_item != null:
		_target_item.get_node("SpritePosition/ItemSprite").material.set_shader_param("line_color", Color.yellow)

func _test_pickup(item: Item) -> void:
	"""Drop the player's current held item if it exists and pick up the new item."""
	if get_child_count() > 0:
		emit_signal("main_player_dropped_item")
	if item != null:
		emit_signal("main_player_picked_up_item", item.get_path())

func pick_up(item: Item) -> void:
	"""Pick up an item."""
	if item == null:
		return
	item.holding_player = player
	picked_up_item = item
	item.picking_up()
	if player.has_node("Infiltrator"):
		player.get_node("Infiltrator").enable_killing(false)

func drop(item: Item) -> void:
	"""Drop an item."""
	if item == null:
		return
	remove_child(item)
	picked_up_item = null
	item.dropped()
	if player.has_node("Infiltrator"):
		player.get_node("Infiltrator").enable_killing(true)

func _on_ItemPickupRange_body_exited(body: Node) -> void:
	if not body.is_in_group("items") or not player.main_player:
		return
	body.get_node("SpritePosition/ItemSprite").material.set_shader_param("line_color", Color.transparent)
	if len(item_pickup_range.get_overlapping_bodies()) <= 0:
		_target_item = null

func _on_ItemPickupRange_body_entered(body: Node) -> void:
	if not body.is_in_group("items") or not player.main_player:
		return
	body.get_node("SpritePosition/ItemSprite").material.set_shader_param("line_color", Color.yellow)

func _on_Player_dead() -> void:
	emit_signal("main_player_dropped_item")
