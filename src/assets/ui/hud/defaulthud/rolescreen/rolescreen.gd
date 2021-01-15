extends ControlBase

onready var player_info_scene: PackedScene = preload("res://assets/ui/hud/defaulthud/rolescreen/player_info.tscn")

onready var display_timer: Timer = $DisplayTimer
onready var team_label: Label = $CenterContainer/TeamLabel
onready var player_info_container: HBoxContainer = $PlayerInfoContainer

var mutex: Mutex = Mutex.new()
func _ready():
	# we need to get notified if new roles get assigned
	# usually happens on the client
	# warning-ignore:return_value_discarded
	PlayerManager.connect("roles_assigned", self, "_on_roles_assigned")
	# we have to call this in case the roles had already been assigned
	# usually happens on the server
	_on_roles_assigned(PlayerManager.playerRoles)
	# warning-ignore:return_value_discarded
	display_timer.connect("timeout", self, "_clean_up")
	
func _clean_up():
	reset()
	UIManager.close_ui("rolescreen")

func reset():
	display_timer.stop()
	for player_info in player_info_container.get_children():
		player_info.queue_free()

func _on_roles_assigned(player_roles: Dictionary):
	if GameManager.state != GameManager.State.Normal:
		return
	# wait here in case that the signal gets emmited, but the call
	# from _ready() hasn't compleated yet
	mutex.lock()
	# a funny thing is observed here.
	# if you comment out reset() and uncomment _clean_up()
	# the server side functions as before, whereas on the client side
	# the rolescreen just blinks(as is the expected behaviour)
	# _clean_up()
	reset()
	populate_player_info_container(player_roles)
	mutex.unlock()

func populate_player_info_container(player_roles: Dictionary):
	display_timer.start()
	var we_are_traitor = PlayerManager.ourrole == "traitor"
	if we_are_traitor:
		# makes _generate_info return only traitor PlayerInfo
		var only_traitor_dict: Dictionary = {
			"traitor": PlayerManager.playerColors["traitor"]}
		_create_info(player_roles, only_traitor_dict)

		team_label.text = "Traitor"
		team_label.set("custom_colors/font_color", PlayerManager.playerColors["traitor"])
	else:
		# _generate_info will return everyone's PlayerInfo
		var everyone_dict: Dictionary = {
			"traitor": PlayerManager.playerColors["default"], # we are camouflaging the traitors
			"default": PlayerManager.playerColors["default"],
			"detective": PlayerManager.playerColors["detective"]}
		_create_info(player_roles, everyone_dict)
		team_label.text = "Good guys"
		team_label.set("custom_colors/font_color", PlayerManager.playerColors["detective"])

# player_roles - only players with player roles contained as keys
# in role_colors will be processed
#
# role_colors - contains player roles as keys and colors as values
#
func _create_info(player_roles: Dictionary, role_colors: Dictionary) -> void:
	var player_index: int = 0

	# filters the players, storing only the ones whose role is in "role_colors"
	var filtered_ids = Array()
	for id in player_roles.keys():
		if role_colors.has(player_roles[id]):
			filtered_ids.append(id)

	# gets the player sprites to be displayed
	var player_group_members = get_tree().get_nodes_in_group("players")
	var player_sprite_collection: Dictionary = {}
	for player in player_group_members:
		if player_roles.has(player.id):
			var skeleton: Node2D = player.get_node("SpritesViewport/Skeleton")
			skeleton = skeleton.duplicate()
			skeleton.use_parent_material = false
			skeleton.scale = Vector2.ONE * 3.0
			var tree: AnimationTree = skeleton.get_node("AnimationPlayer/AnimationTree")
			tree.set("parameters/idle_move_blend/blend_position", Vector2.ZERO)
			player_sprite_collection[player.id] = skeleton

	for id in filtered_ids:
		var y_offset = 0
		if player_index % 2 == 0:
			y_offset = 20
		
		var player_info: VBoxContainer = player_info_scene.instance()
		player_info.get_node("Label").text = Network.get_player_name(id)
		var center_container: CenterContainer = player_info.get_node("CenterContainer")
		center_container.add_child(player_sprite_collection[id])
		player_info_container.add_child(player_info)
		var sprite_position := Vector2(get_viewport().get_visible_rect().size.x / (2 * len(filtered_ids)), center_container.rect_position.y + (center_container.rect_size.y * 3 / 4.0) + y_offset)
		player_sprite_collection[id].global_position = sprite_position

		player_index += 1
