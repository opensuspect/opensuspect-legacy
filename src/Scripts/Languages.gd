extends VBoxContainer

func _ready():
	print(TranslationServer.get_loaded_locales())
	for lang in TranslationServer.get_loaded_locales():
		var btn = Button.new()
		btn.text = lang
		add_child(btn)
