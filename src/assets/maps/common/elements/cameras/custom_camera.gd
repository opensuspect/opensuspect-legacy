extends Camera2D

# Get the players node so we can get the main player to track
onready var players: YSort = get_tree().get_root().get_node("Main/players")
# The minimum position of the camera's upper left corner
onready var limit_min: Position2D = $LimitMin
# The maximum position of the camera's lower right corner
onready var limit_max: Position2D = $LimitMax

# Amount of smoothing applied to camera movement during interpolation
export (float) var smoothing := 2.0
# Amount of zoom to apply to the camera
export (float) var zoom_factor := 0.5
# The camera's viewport dimensions in pixels
onready var camera_dimensions: Vector2

func _ready() -> void:
	set_zoom(Vector2.ONE * zoom_factor)

func _process(delta: float) -> void:
	# Change the camera's dimensions in case the window is resized
	camera_dimensions = get_viewport().get_visible_rect().size * zoom_factor
	# Weird behavior occurs if the camera dimensions are greater than the bounds
	# set by the Position2D nodes
	camera_dimensions.x = clamp(camera_dimensions.x, 0, limit_max.global_position.x - limit_min.global_position.x)
	camera_dimensions.y = clamp(camera_dimensions.y, 0, limit_max.global_position.y - limit_min.global_position.y)
	for player in players.get_children():
		if player.main_player:
			_track_player(player, delta)

func _track_player(player: KinematicBody2D, delta: float) -> void:
	"""
	Tracks a player while staying within the limits specified by child LimitMin 
	and LimitMax Position2D nodes.
	"""
	# Interpolate the camera's offset to the main player's position
	offset = offset.linear_interpolate(player.global_position, delta * smoothing)
	# Make sure camera's extents do not go past set limits
	if offset.x - camera_dimensions.x / 2.0 <= limit_min.global_position.x:
		offset.x = limit_min.global_position.x + camera_dimensions.x / 2.0
	elif offset.x + camera_dimensions.x / 2.0 >= limit_max.global_position.x:
		offset.x = limit_max.global_position.x - camera_dimensions.x / 2.0
	if offset.y - camera_dimensions.y / 2.0 <= limit_min.global_position.y:
		offset.y = limit_min.global_position.y + camera_dimensions.y / 2.0
	elif offset.y + camera_dimensions.y / 2.0 >= limit_max.global_position.y:
		offset.y = limit_max.global_position.y - camera_dimensions.y / 2.0
