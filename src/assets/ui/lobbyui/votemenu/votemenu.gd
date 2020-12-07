extends WindowDialogBase

onready var button_grid: Node = get_node("TabContainer/Vote/VoteControl/VBoxContainer/VoteButtonGrid")

var my_id: int = Network.get_my_id()
# format: {voter network ID: voted for network ID}
var votes: Dictionary = {}

func _ready():
	show()
	# hides x so players can't close the menu
	get_close_button().hide()
	button_grid.connect("vote", self, "vote_for")

func create_vote_buttons():
	button_grid.create_vote_buttons(Network.get_peers())

func vote_for(vote_for: int):
	print("voting for ", vote_for)
	if not get_tree().is_network_server():
		rpc_id(1, "recieve_vote_server", vote_for, my_id)
	else:
		recieve_vote_server(vote_for, my_id)

remote func recieve_vote_server(vote_for: int, vote_from: int):
	if not get_tree().is_network_server():
		return
	rpc("recieve_vote", vote_for, vote_from)

puppetsync func recieve_vote(vote_for: int, vote_from: int):
	print("recieving vote for ", vote_for, " from ", vote_from)
	votes[vote_from] = vote_for
