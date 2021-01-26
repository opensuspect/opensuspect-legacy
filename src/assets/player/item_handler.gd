extends Node2D
class_name ItemHandler

# The player that the item handler is a child of
onready var player: Node = get_owner()
# The area within which items may be picked up
onready var item_pickup_range: Area2D = player.get_node("ItemPickupRange")
onready var pickup_timer: Timer = player.get_node("Timers/PickUp")
var pickup_enabled: bool = true
var in_pickup_range: Array

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
	pickup_timer.connect("timeout", self, "_on_timer_timeout")

func _process(delta: float) -> void:
	if player.main_player:
		pass
#		_get_target()

func _input(event: InputEvent) -> void:
	if not player.main_player or player.is_movement_disabled() or not pickup_enabled or is_PlayerDead():
		return
	if event.is_action_pressed("interact"):
		_test_pickup(_target_item)
	elif event is InputEventMouseButton and event.pressed and event.button_index == BUTTON_LEFT:
		for body in item_pickup_range.get_overlapping_bodies():
			if body.is_in_group("items") and body.can_pickup_with_mouse:
				_test_pickup(body)
				# Avoid picking up multiple objects at once if they're overlapping
				return

func _exit_tree() -> void:
	# Drop the player's item when a player node is destroyed, e.g. when they disconnect
	if get_child_count() == 0:
		return
	# print("(itemhandler.gd/_exit_tree)")
	emit_signal("main_player_dropped_item")

#func _get_target() -> void:
#	"""Every frame, get the nearest item to the player and highlight it in yellow."""
#	var distance: float = INF
#	_target_item = null
#	for body in item_pickup_range.get_overlapping_bodies():
#		if not body.is_in_group("items"):
#			continue
#		body.get_node("SpritePosition/ItemSprite").material.set_shader_param("line_color", Color.transparent)
#		if (body.global_position - player.global_position).length() < distance:
#			distance = (body.global_position - player.global_position).length()
#			_target_item = body
#	if _target_item != null:
#		_target_item.get_node("SpritePosition/ItemSprite").material.set_shader_param("line_color", Color.yellow)

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
	# print("(item_handler.gd/pick_up)")
	item.holding_player = player
	picked_up_item = item
	item.picking_up()

func drop(item: Item) -> void:
	"""Drop an item."""
	if item == null:
		return
	# print("(item_handler.gd/drop)")
	pickup_timer.start()
	pickup_enabled = false
	remove_child(item)
	picked_up_item = null
	item.dropped()

func has_item() -> bool:
	return not picked_up_item == null

func _on_timer_timeout() -> void:
	pickup_enabled = true
	for item in in_pickup_range:
		item.get_node("SpritePosition/ItemSprite").material.set_shader_param("line_color", Color.yellow)
	if _target_item != null:
		_target_item.get_node("SpritePosition/ItemSprite").material.set_shader_param("line_color", Color.green)

func _on_ItemPickupRange_body_exited(body: Node) -> void:
	if not body.is_in_group("items") or not player.main_player:
		return
	if in_pickup_range.has(body):
		in_pickup_range.erase(body)
	body.get_node("SpritePosition/ItemSprite").material.set_shader_param("line_color", Color.transparent)
	if len(in_pickup_range) <= 0:
		_target_item = null
	else:
		_target_item = in_pickup_range[-1]
		_target_item.get_node("SpritePosition/ItemSprite").material.set_shader_param("line_color", Color.green)

func _on_ItemPickupRange_body_entered(body: Node) -> void:
	if not body.is_in_group("items") or not player.main_player or is_PlayerDead():
		return
	if _target_item != null and pickup_enabled:
		_target_item.get_node("SpritePosition/ItemSprite").material.set_shader_param("line_color", Color.yellow)
	in_pickup_range.append(body)
	_target_item = body
	if not pickup_enabled:
		return
	body.get_node("SpritePosition/ItemSprite").material.set_shader_param("line_color", Color.green)

func is_PlayerDead() -> bool:
	return player.get_node("DeathHandler").is_dead

func _on_Player_dead() -> void:
	emit_signal("main_player_dropped_item")
	for item in in_pickup_range:
		item.get_node("SpritePosition/ItemSprite").material.set_shader_param("line_color", Color.transparent)
	if _target_item != null:
		_target_item.get_node("SpritePosition/ItemSprite").material.set_shader_param("line_color", Color.transparent)
	in_pickup_range = []
	_target_item = null
