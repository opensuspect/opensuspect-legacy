extends MarginContainer

class_name MarginContainerBase

export (String) var menu_name

export (bool) var disable_movement

var ui_data: Dictionary = {}

func _init():
# warning-ignore:return_value_discarded
	connect("visibility_changed", self, "_on_visibility_changed")
#called by ui system
func base_open():
	show()

#called by self or ui system
func base_close():
	hide()



func _on_visibility_changed():
	if not disable_movement:
		return
	if visible:
		UIManager.ui_opened(menu_name)
	else:
		UIManager.ui_closed(menu_name)

func get_res() -> Resource:
	var res = TaskManager.get_task_resource(ui_data[TaskManager.TASK_ID_KEY])
	return res
