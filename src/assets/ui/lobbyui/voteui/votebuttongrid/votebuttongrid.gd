extends ScrollContainer

#export(NodePath) var master_node_path

#onready var master_node = get_node(master_node_path)
onready var button_scene: PackedScene = load("res://assets/ui/lobbyui/voteui/votebuttongrid/votebutton/votebutton.tscn")
onready var grid = get_node("GridContainer")

var able_to_select: bool = true
var selected: Node

var buttons: Dictionary

signal vote(player_id)

func _ready():
	pass
#	for i in 10:
#		create_vote_button(i, str(i))

func reset():
	able_to_select = true
	selected = null

func create_vote_buttons(player_ids: Array):
	for button in buttons.values():
		button.queue_free()
	for player in player_ids:
		create_vote_button(player, Network.get_player_name(player))

func create_vote_button(player_id: int, player_name: String, alive: bool = true):
	var new_button: Node = button_scene.instance()
	new_button.name = str(player_id)
# warning-ignore:return_value_discarded
	new_button.connect("pressed", self, "vote_button_pressed", [new_button])
# warning-ignore:return_value_discarded
	new_button.connect("vote", self, "vote_for")
	buttons[player_id] = new_button
	grid.add_child(new_button)
	new_button.init_button(player_id, player_name, alive)

func vote_for(player_id):
	emit_signal("vote", player_id)
	for i in buttons.values():
		i.set_selected(false)
		i.disabled = true
	able_to_select = false

func vote_button_pressed(button: Node):
	if not able_to_select:
		return
#	if selected == button:
#		return
	if selected != null:
		selected.set_selected(false)
	button.set_selected(true)
	selected = button
