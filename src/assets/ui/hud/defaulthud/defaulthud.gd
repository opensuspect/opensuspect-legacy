extends Control


func _ready():
	# warning-ignore:return_value_discarded
	PlayerManager.connect("roles_assigned", self, "_on_roles_assigned")


func _on_roles_assigned(player_roles : Dictionary):
	if GameManager.state != GameManager.State.Normal:
		return
	UIManager.open_ui("roleannouncementui", player_roles)
