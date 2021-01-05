extends Node

enum State { Start, Lobby, Normal }
var state: int = State.Start setget transition, get_state

const TRANSITIONS = {
	State.Start: [State.Lobby],
	State.Lobby: [State.Normal, State.Start],
	State.Normal: [State.Lobby, State.Start],
}

var priority_amount: int = 6
# PRIORITIES:
# 0 : Switching main scenes in scenemanager.gd and toggling accept/refuse connections in network.gd
#     Priority 0 should be reserved for cleanup and extremely essential functions.
# 1 : Switching map in maps.gd
# 2 : Assigning roles in playermanager.gd
# 3 : N/A
# 4 : N/A
# 5 : Spawning players in main.gd

#signals that help sync the gamestate
#can be connected to from anywhere with GameManager.connect("<signal name>", self, "<function name>")
signal state_changed(old_state, new_state)
signal state_changed_priority(old_state, new_state, priority)

func _ready():
	set_network_master(1)
# warning-ignore:return_value_discarded
	get_tree().connect("connected_to_server", self, "_on_connected")
# warning-ignore:return_value_discarded
	Network.connect("server_started", self, "_on_connected")

func transition(new_state: int) -> bool:
	print("attempting to transition gamestate from ", state, " to ", new_state)
	if (TRANSITIONS[state].has(new_state)):
		var old_state: int = state
		state = new_state
		if get_tree().is_network_server():
			rpc("receive_transition", new_state)
		emit_state_changed_signals(old_state, new_state)
		print("(gamemanager.gd, transition) State change signals emitted, transition successful")
		return true
	print("transition failed")
	return false

puppet func receive_transition(new_state: int):
	if get_tree().is_network_server():
		return
	print("attempting to transition gamestate from ", state, " to ", new_state)
	if (TRANSITIONS[state].has(new_state)):
		var old_state: int = state
		state = new_state
		emit_state_changed_signals(old_state, new_state)
		print("(gamemanager.gd, receive_transition) State change signals emitted, transition successful")
		return# true
	print("transition failed")
	return# false

func emit_state_changed_signals(old_state: int, new_state: int):
	# emit state_changed_priority, priority starts at 0
	for priority in priority_amount:
		emit_signal("state_changed_priority", old_state, new_state, priority)
	emit_signal('state_changed', old_state, new_state)

func get_state() -> int:
	return state

func ingame() -> bool:
	return [State.Normal].has(state)

func _on_connected() -> void:
# warning-ignore:return_value_discarded
	transition(State.Lobby)
