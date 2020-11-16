extends PopupBase

class_name PopupTask

#called by ui system
func base_open():
	#call base_open() in parent class
	.base_open()

#called by self or ui system
func base_close():
	#call base_close() in parent class
	.base_close()

# warning-ignore:unused_argument
func _notification(what):
	match what:
		NOTIFICATION_POST_POPUP:
			UIManager.menu_opened(menu_name)
		NOTIFICATION_POPUP_HIDE:
			UIManager.menu_closed(menu_name)
