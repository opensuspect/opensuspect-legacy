extends MarginContainer

signal returnToMainMenu

func _ready() -> void:
	#get_node("../../../CenterContainer").margin_bottom = 208
	default_state()
	print("Loaded locales: ", TranslationServer.get_loaded_locales())

func _on_NewGame_pressed() -> void:
	show_only("PlayGame")

func _on_Settings_pressed() -> void:
	show_only("Settings")

func _on_Return() -> void:
	default_state()

func default_state() -> void:
	#print(get_node("../../../CenterContainer").margin_bottom)
	#get_node("../../../CenterContainer").margin_bottom = 208 #fix title moving to center of screen
	#print(get_node("../../../CenterContainer").margin_bottom)
	show_only("MainMenu")

func show_only(element_name: String) -> void:
	var element: Node = get_node(element_name)
	for child in get_children():
		child.visible = (child == element)

func _on_Quit_pressed() -> void:
	get_tree().quit()

func _on_Back_pressed() -> void:
	default_state()

func _on_Language_pressed() -> void:
	show_only("LanguageMenu")

func _on_MenuArea_returnToMainMenu():
	default_state()
