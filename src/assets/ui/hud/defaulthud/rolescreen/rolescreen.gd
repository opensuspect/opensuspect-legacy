extends Node2D

func _ready():
	# warning-ignore:return_value_discarded
	PlayerManager.connect("roles_assigned", self, "_on_roles_assigned")
	# warning-ignore:return_value_discarded
	$Timer.connect("timeout", self, "_clean_up")
	
	$Label.set_size(get_viewport().size)
	PlayerInfo._set_label_outline($Label)

var player_info : Array

func _clean_up():
	self.hide()
	if self.player_info == null:
		return
	
	for info in self.player_info:
		info.name_label.queue_free()
		info.sprite.queue_free()
	self.player_info.clear()

func _on_roles_assigned(player_roles : Dictionary):
	# just in case the timer didn't fire
	_clean_up()
	if GameManager.state != GameManager.State.Normal:
		return
	
	
	$Timer.start()
	
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
	for info in self.player_info:
		self.add_child(info.name_label)
		self.add_child(info.sprite)
	
	self.show()



const  PLAYER_SPACE_WIDTH = 100
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
	
	# set the player info to the bottom of the screen
	var y_pos = get_viewport().size.y * 0.80
	
	var viewport_width = get_viewport().size.x
	# start drawing player info from here, centered on the middle of the screen
	var x_pos_start = (viewport_width / 2) - ((PLAYER_SPACE_WIDTH * filtered_ids.size()) / 2)
	if x_pos_start < 0:
		# there are too many players to fit in one row.. need to wrap to the next row
		pass
	# assists with lowering every other player info
	var player_count = 0
	
	for id in filtered_ids:
		# draw player info with PLAYER_SPACE_WIDTH pixels in between
		var x_pos = x_pos_start + (PLAYER_SPACE_WIDTH * player_count)
		
		# every other player info should be lowered, to make more room for the name label
		var y_offset = 0
		if player_count % 2 == 0:
			y_offset = 20
	
		p_info.append(PlayerInfo.new(Vector2(x_pos, y_pos + y_offset), id, role_colors[player_roles[id]]))
		player_count += 1
	
	return p_info

class PlayerInfo:
	# this is here as I don't know how to reference it when it's outside of the class
	static func _set_label_outline(label: Label):
	# set the text outline color to black(useful when there are colorful backgrounds)
		label.set("custom_colors/font_color_shadow", Color(0,0,0,1))
		label.set("custom_constants/shadow_as_outline", true)
		
		
	
	var player_texture : Texture = preload("res://assets/player/textures/characters/black/black-proto-1.png")
	
	var name_label : Label
	var sprite : Sprite
	
	func _init(position: Vector2, id: int, player_name_color: Color):
		var player_name = String(Network.get_player_name(id))
		
		self.name_label = Label.new()
		self.name_label.align = Label.ALIGN_CENTER
		self.name_label.text = player_name
		self.name_label.set("custom_colors/font_color", player_name_color)
		
		_set_label_outline(self.name_label)
		
		
		self.sprite = Sprite.new()
		self.sprite.texture = player_texture
		self.sprite.set_position(position)
		
		# center the label above the player sprite
		var width = self.name_label.get_combined_minimum_size().x
		self.name_label.rect_position = position
		self.name_label.rect_position.x -= (width/2)
		# position the label a bit above the player sprite
		self.name_label.rect_position.y -= 50
