extends WindowDialog

class_name WindowDialogBase

export (String) var menu_name

export (bool) var disable_movement

var ui_data: Dictionary = {}

#called by ui system
func base_open():
	popup()

#called by self or ui system
func base_close():
	hide()

# warning-ignore:unused_argument
func _notification(what):
	if not disable_movement:
		return
	match what:
		NOTIFICATION_POST_POPUP:
			UIManager.ui_opened(menu_name)
		NOTIFICATION_POPUP_HIDE:
			UIManager.ui_closed(menu_name)
