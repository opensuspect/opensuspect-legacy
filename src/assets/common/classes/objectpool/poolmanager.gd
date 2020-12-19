extends Node
class_name PoolManager

# System to create a pool of objects once and spawn/recycle them as they are
# needed, eliminating the need to call instance() and queue_free() many times.
# https://gameprogrammingpatterns.com/object-pool.html

# Emitted when an object pool is created
signal pool_created(pool)
# Emitted when an object pool is destroyed
signal pool_destroyed(pool)
# Emitted when an object is spawned from its pool
signal object_spawned(object)
# Emitted when an object is recycled back to its pool
signal object_recycled(object)

# Objects that are spawned and active
var _spawned_objects: Array = [] setget , get_spawned_objects
# Objects that are recycled and inactive
var _recycled_objects: Array = [] setget , get_recycled_objects

func create_pool(pool_name: String, pool_object: IPoolable, size: int = 100, manager: PoolManager = self) -> ObjectPool:
	"""Creates a pool of objects."""
	var object_pool := ObjectPool.new(pool_object, size)
	object_pool.name = pool_name
	self.add_child(object_pool)
	self.emit_signal("pool_created", object_pool)
	return object_pool

func destroy_pool(pool_name: String) -> void:
	"""Destroys an object pool."""
	if not has_node(pool_name):
		return
	var object_pool: ObjectPool = get_node(pool_name)
	object_pool.queue_free()
	self.emit_signal("pool_destroyed", object_pool)

func get_pool(pool_name: String) -> ObjectPool:
	"""Gets an object pool by its name."""
	for object_pool in get_children():
		if object_pool.name == pool_name:
			return object_pool
	return null

func recycle(object: IPoolable) -> void:
	"""Recycles an object into its respective pool."""
	for object_pool in get_children():
		if object_pool.object_references.has(object):
			object_pool.recycle(object)
			self._spawned_objects.erase(object)
			self._recycled_objects.append(object)
			self.emit_signal("object_recycled", object)

func spawn(object: IPoolable) -> IPoolable:
	"""Spawns an object from its pool."""
	for object_pool in get_children():
		if object_pool.pool.has(object):
			self._spawned_objects.append(object)
			self._recycled_objects.erase(object)
			self.emit_signal("object_spawned", object)
			return object_pool.spawn()
	return null

func spawn_from_pool(pool_name: String) -> IPoolable:
	"""Spawns an object from its pool by the pool's name."""
	for object_pool in get_children():
		if object_pool.name == pool_name and len(object_pool.pool) > 0:
			var object: IPoolable = object_pool.spawn()
			self._spawned_objects.append(object)
			self._recycled_objects.erase(object)
			self.emit_signal("object_spawned", object)
			return object
	return null

func get_spawned_objects() -> Array:
	"""Gets an array of spawned objects within the pool manager."""
	return _spawned_objects

func get_recycled_objects() -> Array:
	"""Gets an array of recycled objects within the pool manager."""
	return _recycled_objects



class ObjectPool extends Node:
	# Pool of objects; modified as objects are spawned and recycled
	var pool: Array = []
	# Contains references to the initialized pool of objects; doesn't change 
	# when an object is spawned
	var object_references: Array = []
	# The size of this object pool
	var size: int
	# The object that this pool will spawn and recycle
	var object: IPoolable

	# Class constructor
	func _init(pool_object: IPoolable, size: int) -> void:
		self.object = pool_object
		self.size = size
		self._init_pool()

	func spawn() -> IPoolable:
		"""Spawns an object."""
		if len(self.pool) <= 0:
			return null
		var spawned_object: IPoolable = self.pool.pop_back()
		spawned_object.spawned()
		self.add_child(spawned_object)
		return spawned_object

	func recycle(_object: IPoolable) -> void:
		"""Recycles an object."""
		if len(self.pool) < size and self.object_references.has(_object):
			_object.recycled()
			self.remove_child(_object)
			self.pool.push_back(_object)

	func _init_pool() -> void:
		"""Initializes the object pool."""
		for i in range(self.size):
			var new_object: IPoolable = self.object.duplicate()
			self.pool.push_back(new_object)
			self.object_references.push_back(new_object)
