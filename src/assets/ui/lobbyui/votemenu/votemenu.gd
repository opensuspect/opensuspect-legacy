extends WindowDialogBase

onready var button_grid: Node = get_node("TabContainer/Vote/VoteControl/VBoxContainer/VoteButtonGrid")

func _ready():
	show()
	get_close_button().hide()
	button_grid.connect("vote", self, "vote_for")

func vote_for(player_id):
	print("voting for ", player_id)

#func _on_visibility_changed():
#	if visible:
#		UIManager.ui_opened("votemenu")
#	else:
#		UIManager.ui_closed("votemenu")
