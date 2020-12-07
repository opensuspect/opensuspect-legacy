extends PopupBase

# gets updated by the UIManager
# holds the assigned player roles
export var ui_data: Dictionary

func base_open():
	.base_open()# we need to 'pop up'
	# warning-ignore:return_value_discarded
	$Timer.connect("timeout", self, "_clean_up")
	# warning-ignore:return_value_discarded
	GameManager.connect("state_changed", self, "_clean_up")# HELP<<-- Never gets called
	PlayerInfo._set_label_outline($Label)
	show_roles(ui_data)
	$Timer.start()

func _clean_up():
	$Timer.stop()
	PlayerManager.inMenu = false
	UIManager.free_ui("roleannouncementui")

func show_roles(player_roles : Dictionary):
	PlayerManager.inMenu = true
	var player_info: Array
	var we_are_traitor = PlayerManager.ourrole == "traitor"
	if we_are_traitor:
		# makes _generate_info return only traitor PlayerInfo
		var only_traitor_dict: Dictionary = {
			"traitor": PlayerManager.playerColors["traitor"]}
			
		player_info = _generate_info(player_roles, only_traitor_dict)
		
		$Label.text = "Traitor"
		$Label.set("custom_colors/font_color", PlayerManager.playerColors["traitor"])
	else:
		# _generate_info will return everyone's PlayerInfo
		var everyone_dict: Dictionary = {
			"traitor": PlayerManager.playerColors["default"], # we are camouflaging the traitors
			"default": PlayerManager.playerColors["default"], 
			"detective": PlayerManager.playerColors["detective"]}
		player_info = _generate_info(player_roles, everyone_dict)
		$Label.text = "Good guys"
		$Label.set("custom_colors/font_color", PlayerManager.playerColors["detective"])
	
	# Center the team label
	var team_label_width = $Label.get_combined_minimum_size().x
	var team_label_pos = $Label.get_position()
	team_label_pos.x -= team_label_width/4
	$Label.set_position(team_label_pos)
	
	for info in player_info:
		self.add_child(info.name_label)
		
# player_roles - only players with player roles contained as keys
# in role_colors will be processed
#
# role_colors - contains player roles as keys and colors as values
# 
# returns - array of PlayerInfo objects, of filtered players
func _generate_info(player_roles: Dictionary, role_colors: Dictionary):
	var p_info : Array = Array()
	
	# filters the players, storing only the ones whose role is in "role_colors"
	var filtered_ids = Array() 
	for id in player_roles.keys():
		if role_colors.has(player_roles[id]):
			filtered_ids.append(id)
	
	# gets the player texture to be displayed
	# or, displays the black spacesuit character,
	# if the customized player texture wasn't found
	var player_group_members = get_tree().get_nodes_in_group("players")
	var player_texture_collection = Dictionary()
	var total_texture_width = 0.0
	for player in player_group_members:
		if not filtered_ids.has(player.id):
			continue
		var player_texture = PlayerManager.get_player_texture(player)
		if player_texture == null:
			player_texture = PlayerManager.get_defalut_player_texture()
		player_texture_collection[player.id] = player_texture
		total_texture_width += player_texture.get_width()
	
	# assists with positioning player info
	var player_count = 0
	var average_texture_width = total_texture_width / filtered_ids.size()
	var texture_ratio = average_texture_width / get_viewport().get_size().x
	var anchor_spacing = 1.0 / filtered_ids.size()
	
	for id in filtered_ids:
		# find the middle, so every player is placed evenly-ish apart
		var x_anchor = (anchor_spacing * player_count) + (anchor_spacing / 2) - (texture_ratio/4)
		# every other player info should be lowered, to make more room for the name label
		var y_anchor = 0.7
		if player_count % 2 == 0:
			y_anchor = 0.6
	
		p_info.append(PlayerInfo.new(	Vector2(x_anchor, y_anchor),
										id,
										role_colors[player_roles[id]],
										player_texture_collection[id]))
		player_count += 1
	
	return p_info

class PlayerInfo:
	# this is here as I don't know how to reference it when it's outside of the class
	static func _set_label_outline(label: Label):
	# set the text outline color to black(useful when there are colorful backgrounds)
		label.set("custom_colors/font_color_shadow", Color(0,0,0,1))
		label.set("custom_constants/shadow_as_outline", true)
	
	var name_label : Label
	
	const SCALE_FACTOR = 0.6
	const SCALE_FACTOR_LABEL = SCALE_FACTOR * 2.0
	func _init(		anchors: Vector2, 
					id: int,
					player_name_color: Color,
					player_texture: Texture):
		
		
		var player_name = String(Network.get_player_name(id))
		
		self.name_label = Label.new()
		self.name_label.align = Label.ALIGN_CENTER
		self.name_label.text = player_name
		self.name_label.set_scale(Vector2(SCALE_FACTOR_LABEL, SCALE_FACTOR_LABEL))
		self.name_label.set("custom_colors/font_color", player_name_color)
		
		_set_label_outline(self.name_label)
		var sprite = Sprite.new()
		sprite.texture = player_texture
		sprite.set_scale(Vector2(SCALE_FACTOR, SCALE_FACTOR))
		
		var spacing_h = player_texture.get_height() * SCALE_FACTOR
		var spacing_label = self.name_label.get_combined_minimum_size().y * (SCALE_FACTOR_LABEL)
		sprite.set_position(Vector2(0, (spacing_h / 4) + spacing_label / 2))
		var center = Control.new()
		center.add_child(sprite)
		# Center horizontally
		center.set_anchor(MARGIN_TOP, 1)
		center.set_anchor(MARGIN_LEFT, 0.5)
		self.name_label.add_child(center)

		self.name_label.set_anchor(MARGIN_LEFT, anchors.x)
		self.name_label.set_anchor(MARGIN_TOP, anchors.y)
