extends YSort
signal positions_updated(last_received_input)

# Called from server when the server's players move
puppet func update_positions(positions_dict: Dictionary, last_received_input: int) -> void:
	for id in positions_dict.keys():
		if get_parent().players.keys().has(id):
			get_parent().players[id].move_to(positions_dict[id][0], positions_dict[id][1])
			get_parent().players[id].velocity = positions_dict[id][2]
	emit_signal("positions_updated", last_received_input)

func _on_main_player_moved(movement: Vector2, velocity: Vector2, last_input: int):
	if not get_tree().is_network_server():
		rpc_id(1, "player_moved", movement, velocity, last_input)

# Keep the clients' player positions updated
func _physics_process(_delta: float) -> void:
	if get_tree().is_network_server():
		var positions_dict = {}
		for id in get_parent().players.keys():
			positions_dict[id] = [get_parent().players[id].position, get_parent().players[id].movement, get_parent().players[id].velocity]
		for id in get_parent().players.keys():
			if id != 1:
				rpc_id(id, "update_positions", positions_dict, get_parent().players[id].input_number)

func get_network_id_from_player_node_name(node_name: String) -> int:
	"""Fetch a player's network ID from the name of their KinematicBody2D."""
	var players_dict: Dictionary = PlayerManager.players
	var players_array: Array = players_dict.values()
	for index in range(len(players_array)):
		if players_array[index].name == node_name:
			return players_dict.keys()[index]
	return -1

# Called from client side to tell the server about the player's actions
remote func player_moved(new_movement: Vector2, velocity: Vector2, last_input: int) -> void:
	# Should only be run on the server
	if !get_tree().is_network_server():
		return
	var id = get_tree().get_rpc_sender_id()
	if not get_parent().players.keys().has(id):
		return
	# Check movement validity
	if new_movement.length() > 1:
		new_movement = new_movement.normalized()
	get_parent().players[id].movement = new_movement
	get_parent().players[id].input_number = last_input


func _on_infiltrator_kill(killer: KinematicBody2D, killed_player: KinematicBody2D) -> void:
	"""
	Runs on the infiltrator's Main scene; sends an RPC to the server to indicate
	that the infiltrator has killed a player, and also sends an RPC to the server
	to initiate a check whether the win conditions have been achieved.
	"""
	var killer_id: int = get_network_id_from_player_node_name(killer.name)
	var killed_player_id: int = get_network_id_from_player_node_name(killed_player.name)
	
	if not get_parent().players.keys().has(killer_id) or not get_parent().players.keys().has(killed_player_id):
		return
	if get_tree().is_network_server():
		# Killer is the network server
		infiltrator_killed_player(killer_id, killed_player_id)
		#check if a round ends due to passing winning conditions:
		get_parent().get_node("winlosscontroller").victory_check() 
	else:
		rpc_id(1, "infiltrator_killed_player", killer_id, killed_player_id)
		#ask the server to check if a round ends due to passing winning conditions:
		get_parent().get_node("winlosscontroller").rpc_id(1, "victory_check")
remote func infiltrator_killed_player(killer_id: int, killed_player_id: int) -> void:
	"""
	Runs on the server; sends an RPC to every player to indicate that a
	particular player has been killed.
	"""
	if not get_tree().is_network_server():
		return

	for player_id in get_parent().players.keys():
		rpc_id(player_id, "player_killed", killer_id, killed_player_id)

puppetsync func player_killed(killer_id: int, killed_player_id: int) -> void:
	"""Runs on a client; responsible for actually killing off a player."""
	var killed_player_death_handler: Node2D = get_parent().players[killed_player_id].get_node("DeathHandler")
	killed_player_death_handler.die_by(killer_id)
