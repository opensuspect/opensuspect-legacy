extends YSort

puppetsync func end_round(winner):
	"""This function is called by the server and when it is, it would need to
	show the win / lose screens for the players, and then transitions back
	to the lobby."""
	var main_player = get_parent().main_player_id()
	if main_player == -1:
		#TODO
		#Here should be the code for whatever happens on a dedicated server at the
		#end of the turn
		pass
	elif PlayerManager.get_player_team(main_player):
		#TODO
		#Here should be the code for displaying the victory screen
		pass
	else:
		#TODO
		#Here should be the code for displaying the defeat screen
		pass
	GameManager.transition(GameManager.State.Lobby)

master func victory_check():
	"""Checks all possible victory conditions, and if any passes, tells all clients
	to proceed to the victory / defeat screens"""
	var victorious: int
	
	victorious = -1
	#TODO:
	#Here, there should be a check whether the current map allows for elimination victory ot not
	if victorious == -1:
		victorious = elimination_victory_check(0)
	#TODO
	#Here, all other victory conditions should be checked.
	if victorious != -1:
		for player_id in get_parent().get_node("players").players.keys():
			rpc_id(player_id, "end_round", victorious)

func elimination_victory_check(main_team: int):
	"""Checks whether the elimination victory has been achieved. Returns -1
	if no one wins, otherwise returns the number of the winning tean
	main_team: this variable is the team number of the team that needs to keep
		hold of the majority of the players, and they only win if every other team
		got eliminated."""
	var players_left = {}
	var players_team: int
	var enabled_teams
	var total_players = 0
	var max_member = -1
	var max_team = -1
	
	#Counting up the alive members of each teams
	enabled_teams = PlayerManager.get_enabledTeams()
	for team in enabled_teams:
		players_left[team] = 0
	for player in PlayerManager.players.keys():
		if PlayerManager.players[player].get_is_alive():
			players_team = PlayerManager.get_player_team(player)
			players_left[players_team] = players_left[players_team] + 1
	
	#Looks for the team with the largest number of players except the main team
	#In case of a tie in terms of player numbers, the lower team number will
	#be handled as the majority: if everyone of the main team is dead, and two-two
	#players are left alive from teams 1 and 2, team 1 wins
	for team in enabled_teams:
		total_players = total_players + players_left[team]
		if players_left[team] > max_member and team != main_team:
			max_member = players_left[team]
			max_team = team
	
	if total_players == players_left[main_team]:
		#All players who are left are from the main team, no infiltrators remain
		return main_team
	elif max_member >= total_players-max_member:
		#Any infiltrator team that managed to get at least 50% of alive players, wins
		return max_team
	
	return -1
