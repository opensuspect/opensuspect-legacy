extends PopupPanel

class_name PopupPanelBase

export (String) var menu_name

#called by ui system
func base_open():
	popup()

#called by self or ui system
func base_close():
	hide()

# warning-ignore:unused_argument
func _notification(what):
	match what:
		NOTIFICATION_POST_POPUP:
			UIManager.menu_opened(menu_name)
		NOTIFICATION_POPUP_HIDE:
			UIManager.menu_closed(menu_name)
