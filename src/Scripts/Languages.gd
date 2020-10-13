extends VBoxContainer

class LanguageSorter:
	static func sort_ascending(foo, bar) -> bool:
		return TranslationServer.get_locale_name(foo) < TranslationServer.get_locale_name(bar)

func _ready() -> void:
	var languages: Array = TranslationServer.get_loaded_locales()
	languages.sort_custom(LanguageSorter, "sort_ascending")
	for lang in languages:
		var btn = Button.new()
		btn.flat = true
		btn.text = TranslationServer.get_locale_name(lang)
		btn.connect("pressed", self, "set_language", [lang])
		add_child(btn)

func set_language(lang: String) -> void:
	TranslationServer.set_locale(lang)
