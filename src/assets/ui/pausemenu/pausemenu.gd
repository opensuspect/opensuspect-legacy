extends ControlBase

func _ready():
	pass

func _process(_delta):
	margin_left = $menu.margin_left
	margin_right = $menu.margin_right
	margin_top = $menu.margin_top
	margin_bottom = $menu.margin_bottom

func open() -> void:
	show()

func close() -> void:
	hide()

func show_only(node_name: String):
	if not get_node(node_name):
		return
	for i in get_children():
		i.hide()
	get_node(node_name).show()

func _on_resume_pressed():
	_resume_game()

func _on_appearance_pressed():
	UIManager.open_ui("appearance_editor")
	UIManager.ui_opened("appearance_editor")

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

func _resume_game() -> void:
	UIManager.close_ui("pausemenu")

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") and visible and UIManager.current_ui == self:
		_resume_game()
