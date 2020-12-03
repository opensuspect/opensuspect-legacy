extends Node2D

onready var player: KinematicBody2D = get_owner()
onready var item_pickup_range: Area2D = player.get_node("ItemPickupRange")
onready var maps: YSort = get_tree().get_root().get_node("Main/maps")
onready var map_items: YSort

signal main_player_picked_up_item(item_path)
signal main_player_dropped_item(item_path)

var _target_item: KinematicBody2D
var picked_up_item: KinematicBody2D

func _process(delta: float) -> void:
	if player.main_player:
		_get_target()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("interact"):
		if get_child_count() > 0:
			drop(get_child(0))
#			emit_signal("main_player_dropped_item", get_child(0).get_path())
		if _target_item != null:
			pick_up(_target_item)
#			emit_signal("main_player_picked_up_item", _target_item.get_path())

func _get_target() -> void:
	var distance: float = INF
	_target_item = null
	for body in item_pickup_range.get_overlapping_bodies():
		body.material.set_shader_param("line_color", Color.transparent)
		if (body.global_position - player.global_position).length() < distance:
			distance = (body.global_position - player.global_position).length()
			_target_item = body
	if _target_item != null:
		_target_item.material.set_shader_param("line_color", Color.yellow)

func pick_up(item: KinematicBody2D) -> void:
	item.get_parent().remove_child(item)
	add_child(item)
	item.set_collision_layer_bit(4, false)
	item.position = Vector2.ZERO

func drop(item: KinematicBody2D) -> void:
	if map_items == null:
		 map_items = maps.get_child(0).get_node("Items")
	var offset: Vector2 = item.global_position - map_items.global_position
	remove_child(item)
	map_items.add_child(item)
	item.position = offset
	item.set_collision_layer_bit(4, true)

func _on_ItemPickupRange_body_exited(body: Node) -> void:
	body.material.set_shader_param("line_color", Color.transparent)
	if len(item_pickup_range.get_overlapping_bodies()) <= 0:
		_target_item = null
