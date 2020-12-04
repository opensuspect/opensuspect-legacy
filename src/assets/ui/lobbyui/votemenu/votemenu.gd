extends WindowDialogBase

onready var button_grid: Node = get_node("TabContainer/Vote/VoteControl/VBoxContainer/VoteButtonGrid")

func _ready():
	show()
	# hides x so players can't close the menu
	get_close_button().hide()
	button_grid.connect("vote", self, "vote_for")

func vote_for(player_id):
	print("voting for ", player_id)
