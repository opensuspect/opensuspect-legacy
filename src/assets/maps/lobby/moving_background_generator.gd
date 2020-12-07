extends Node2D

onready var spawn_timer: Timer = $SpawnTimer
onready var pool_manager: PoolManager = $PoolManager

# The maximum distance between the scroll target and the spawned object before
# the object is recycled
const despawn_threshold: float = 5.0

# The path to the object that will be spawned in this generator
export (String) var object_to_spawn_path := "res://assets/maps/lobby/tree.tscn"
# The size of the child pool manager's object pool
export (int) var pool_size := 10
# The local coordinates that spawned objects will scroll to
export (Vector2) var scroll_target := Vector2.LEFT * 1000
# The minimum distance that an object will spawn away from the camera
export (int) var distance_min := 100
# The maximum distance that an object will spawn away from the camera
export (int) var distance_max := 200
# The minimum time between object spawns
export (float) var spawn_delay_min := 0.5
# The maximum time between object spawns
export (float) var spawn_delay_max := 1.0
# Whether to initially spawn objects so they appear in the scene before scrolling
export (bool) var initial_spawn := true
# Number of objects to initially spawn
export (int) var num_initial_spawn := 10
# The minimum local spawn position of the prespawned object(s)
export (Vector2) var initial_spawn_position_min := Vector2.LEFT * 500
# The maximum local spawn position of the prespawned object(s)
export (Vector2) var initial_spawn_position_max := Vector2.RIGHT * 500
# The path to the background which will be used to blend objects
export (NodePath) var background_path
# The distance that the background is away from the camera
export (float) var background_distance := 4096

# The scene of the object that will be spawned
onready var object_to_spawn: PackedScene = load(object_to_spawn_path)
# The background which will be used to blend objects
onready var background: Node = get_node(background_path)

# Holds scroll speeds associated with each spawned object
var scroll_speeds: Array = []

func _ready() -> void:
	scroll_target += global_position
	var temp_instance: IPoolable = object_to_spawn.instance()
	pool_manager.create_pool("MovingObjects", temp_instance, pool_size)
	temp_instance.queue_free()
	if initial_spawn:
		for i in range(num_initial_spawn):
			var initial_spawn_x: float = rand_range(initial_spawn_position_min.x, initial_spawn_position_max.x)
			var initial_spawn_y: float = rand_range(initial_spawn_position_min.y, initial_spawn_position_max.y)
			var initial_spawn_position := Vector2(initial_spawn_x + global_position.x, initial_spawn_y + global_position.y)
			_spawn_object(initial_spawn_position)
	_reset_spawn_timer()

func _physics_process(delta: float) -> void:
	var spawned_objects: Array = pool_manager.get_spawned_objects()
	for object in spawned_objects:
		var index: int = spawned_objects.find(object)
		var instance: BackgroundObject = spawned_objects[index]
		instance.global_position = instance.global_position.move_toward(scroll_target, scroll_speeds[index] * delta)
		if (scroll_target - instance.global_position).length() <= despawn_threshold:
			scroll_speeds.remove(index)
			pool_manager.recycle(instance)

func _spawn_object(global_spawn_position: Vector2) -> void:
	"""
	Spawns an object at 'global_spawn_position', setting a random distance and
	modifying properties based on it.
	"""
	randomize()
	var distance: int = randi() % distance_max + distance_min

	if object_to_spawn == null:
		return

	var instance: BackgroundObject = pool_manager.spawn_from_pool("MovingObjects")
	if instance == null:
		return
	instance.global_position = global_spawn_position
	instance.z_index = -floor(distance / 10)
	instance.scale = Vector2.ONE * (100.0 / distance) if distance > 0 else 1.0
	var texture: Texture = instance.sprite.texture
	var offset: float = 1.0 / (texture.get_size().y * instance.scale.y * instance.sprite.scale.y)
	instance.sprite.position += Vector2.UP * offset
	scroll_speeds.append((50_000.0 / distance) if distance > 0 else 50_000)
	if not instance.material is ShaderMaterial or not background is ColorRect:
		return
	instance.material.set_shader_param("tint_color", background.color)
	instance.material.set_shader_param("tint_amount", -instance.z_index / float(background_distance))

func _reset_spawn_timer() -> void:
	"""Reset the spawn timer with a randomized time."""
	var spawn_delay: float = rand_range(spawn_delay_min, spawn_delay_max)
	spawn_timer.wait_time = spawn_delay
	spawn_timer.start()

func _on_SpawnTimer_timeout() -> void:
	_spawn_object(global_position)
	_reset_spawn_timer()
