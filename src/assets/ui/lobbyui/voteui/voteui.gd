extends WindowDialogBase

onready var button_grid: Node = get_node("TabContainer/Vote/VoteControl/VBoxContainer/VoteButtonGrid")
onready var chatbox: Node = get_node("TabContainer/Chat/chatboxbase")

var my_id: int = Network.get_my_id()
# format: {voter network ID: voted for network ID}
var votes: Dictionary = {}

func _ready():
	# hides x so players can't close the menu
	#get_close_button().hide()
# warning-ignore:return_value_discarded
	button_grid.connect("vote", self, "vote_for")
	create_vote_buttons()

func open():
	chatbox.update()
	reset()

func reset():
	votes = {}
	button_grid.reset()
	create_vote_buttons()

func check_all_players_voted() -> bool:
	for player in Network.get_peers():
		if not votes.has(player):
			return false
	return true

func vote_for(vote_for: int):
	print("voting for ", vote_for, ", my id: ", my_id)
	rpc_id(1, "recieve_vote_server", vote_for, my_id)

remotesync func recieve_vote_server(vote_for: int, vote_from: int):
	if not get_tree().is_network_server():
		return
	if get_tree().get_rpc_sender_id() != vote_from:
		return
	print("server recieving vote for ", vote_for, " from ", vote_from)
	rpc("recieve_vote", vote_for, vote_from)
	print(check_all_players_voted())

puppetsync func recieve_vote(vote_for: int, vote_from: int):
	print("recieving vote for ", vote_for, " from ", vote_from)
	votes[vote_from] = vote_for

func create_vote_buttons():
	button_grid.create_vote_buttons(Network.get_peers())
