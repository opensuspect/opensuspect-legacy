extends VBoxContainer

func _ready() -> void:
	for lang in TranslationServer.get_loaded_locales():
		var btn = Button.new()
		btn.flat = true
		btn.text = TranslationServer.get_locale_name(lang)
		btn.connect("pressed", self, "set_language", [lang])
		add_child(btn)

func set_language(lang: String) -> void:
	TranslationServer.set_locale(lang)
