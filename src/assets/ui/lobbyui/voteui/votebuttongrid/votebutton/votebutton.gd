extends Button

onready var confirm_cancel: Node = get_node("MarginContainer/ConfirmCancelButtons")
onready var name_text: Node = get_node("MarginContainer/HBoxContainer/NameText")

var player_id: int
var player_name: String
var alive: bool = true

var selected: bool = false

signal vote(player_id)

func _ready():
	confirm_cancel.hide()
	if not alive:
		disabled = true

# get the button set up
func init_button(button_player_id: int, button_player_name: String, alive: bool = true):
	player_id = button_player_id
	player_name = button_player_name
	text = ""
	name_text.text = button_player_name
	if not alive:
		disabled = true

# show that this player has voted
func show_voted():
	pass

# show who voted for this player
func show_votes(voters: Array):
	pass

func set_selected(value):
	if value:
		show_confirm_cancel()
		selected = true
	else:
		hide_confirm_cancel()
		selected = false

func show_confirm_cancel():
	confirm_cancel.show()

func hide_confirm_cancel():
	confirm_cancel.hide()

func _on_confirm_pressed():
	emit_signal("vote", player_id)
	set_selected(false)

func _on_cancel_pressed():
	hide_confirm_cancel()
	selected = false
