extends PopupBase

func _ready():
	pass

func _process(_delta):
	margin_left = $menu.margin_left
	margin_right = $menu.margin_right
	margin_top = $menu.margin_top
	margin_bottom = $menu.margin_bottom

func show_only(node_name: String):
	if not get_node(node_name):
		return
	for i in get_children():
		i.hide()
	get_node(node_name).show()

func _on_pausemenu_about_to_show():
	pass

func _on_pausemenu_popup_hide():
	pass
#	close()

func _on_resume_pressed():
	hide()

func _on_appearance_pressed():
	pass # Replace with function body.

func _on_settings_pressed():
	show_only("settings")

func _on_Return():
	show_only("menu")

func _on_language_pressed():
	pass # Replace with function body.

func _on_leave_pressed():
	Network.terminate_connection()

func _on_quit_pressed():
	get_tree().quit()
