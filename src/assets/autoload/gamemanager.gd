extends Node

enum State { Start, Lobby, Normal }
var state: int = State.Start setget transition, get_state

const TRANSITIONS = {
	State.Start: [State.Lobby],
	State.Lobby: [State.Normal, State.Start],
	State.Normal: [State.Lobby, State.Start],
}

#signals that help sync the gamestate
#can be connected to from anywhere with GameManager.connect("<signal name>", self, "<function name>")
signal state_changed

func _ready():
	set_network_master(1)
	get_tree().connect("connected_to_server", self, "_on_connected")
	Network.connect("server_started", self, "_on_connected")

func transition(new_state) -> bool:
	print("attempting to transition gamestate from ", state, " to ", new_state)
	if (TRANSITIONS[state].has(new_state)):
		var old_state: int = state
		state = new_state
		emit_signal('state_changed', old_state, new_state)
		if get_tree().is_network_server():
			rpc("receiveTransition", new_state)
		print("transition successful")
		return true
	print("transition failed")
	return false

puppet func receiveTransition(new_state):
	if get_tree().is_network_server():
		return
	print("attempting to transition gamestate from ", state, " to ", new_state)
	if (TRANSITIONS[state].has(new_state)):
		var old_state: int = state
		state = new_state
		emit_signal('state_changed', old_state, new_state)
		print("transition successful")
		return# true
	print("transition failed")
	return# false

func get_state() -> int:
	return state

func ingame() -> bool:
	return [State.Normal].has(state)

func _on_connected() -> void:
	transition(State.Lobby)
