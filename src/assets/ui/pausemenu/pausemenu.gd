extends Popup

func _ready():
	popup()

func _process(_delta):
	margin_left = $CenterContainer.margin_left
	margin_right = $CenterContainer.margin_right
	margin_top = $CenterContainer.margin_top
	margin_bottom = $CenterContainer.margin_bottom

func _on_pausemenu_about_to_show():
	pass # Replace with function body.

func _on_resume_pressed():
	hide()

func _on_appearance_pressed():
	pass # Replace with function body.

func _on_settings_pressed():
	pass # Replace with function body.

func _on_language_pressed():
	pass # Replace with function body.

func _on_quit_pressed():
	get_tree().quit()
