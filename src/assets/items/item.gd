extends KinematicBody2D
class_name Item

onready var map_items: Node2D
onready var animator: AnimationPlayer = $ItemAnimator

const pickup_speed: float = 35.0
const picked_up_threshold: float = 5.0

var can_pickup_with_mouse: bool
var holding_player: Player
var being_held: bool
var being_picked_up: bool

func _ready() -> void:
	$ItemAnimator.play("hover")

	# Wait another frame for map to finish setting up
	yield(get_tree(), "idle_frame")
	# print("(items.gd/_ready)")
	map_items = MapManager.get_current_map().items

func _physics_process(delta: float) -> void:
	if being_picked_up:
		if holding_player == null:
			being_picked_up = false
			return
		global_position = global_position.linear_interpolate(holding_player.global_position, delta * pickup_speed)
		if (global_position - holding_player.global_position).length() <= picked_up_threshold:
			being_picked_up = false
			picked_up()

func picked_up() -> void:
	"""Item is picked up."""
	set_collision_layer_bit(4, false)
	being_held = true
	map_items.remove_child(self)
	holding_player.item_handler.add_child(self)
	position = Vector2.ZERO

func picking_up() -> void:
	"""Item is being picked up."""
	animator.play("idle", 0.25)
	being_picked_up = true

func dropped() -> void:
	"""Item has been dropped."""
	animator.play("hover")
	map_items.add_child(self)
	global_position = holding_player.global_position - map_items.global_position
	being_held = false
	holding_player = null
	set_collision_layer_bit(4, true)

func _on_MouseArea_mouse_entered() -> void:
	can_pickup_with_mouse = true

func _on_MouseArea_mouse_exited() -> void:
	can_pickup_with_mouse = false
