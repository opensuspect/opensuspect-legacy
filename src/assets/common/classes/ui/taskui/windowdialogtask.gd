extends WindowDialogMenu

class_name WindowDialogTask

func _ready():
# warning-ignore:return_value_discarded
	connect("about_to_show", self, "_windowdialogtask_about_to_show")
# warning-ignore:return_value_discarded
	connect("popup_hide", self, "_windowdialogtask_popup_hide")

func _windowdialogtask_about_to_show():
	pass

func _windowdialogtask_popup_hide():
	pass
