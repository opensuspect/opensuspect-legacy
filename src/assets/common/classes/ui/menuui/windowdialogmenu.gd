extends WindowDialog

class_name WindowDialogMenu

export (String) var menu_name

func _ready():
# warning-ignore:return_value_discarded
	connect("about_to_show", self, "_windowdialogmenu_about_to_show")
# warning-ignore:return_value_discarded
	connect("popup_hide", self, "_windowdialogmenu_popup_hide")

#called by ui system
func base_open():
	popup()

#called by self or ui system
func base_close():
	hide()

func _windowdialogmenu_about_to_show():
	UIManager.menu_opened(menu_name)

func _windowdialogmenu_popup_hide():
	UIManager.menu_closed(menu_name)
