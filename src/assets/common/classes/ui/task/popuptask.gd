extends PopupBase

class_name PopupTask

func complete_task(data: Dictionary = {}):
	if TaskManager.complete_task(ui_data["task_id"], data):
		base_close()

#called by ui system
func base_open():
	var task_state: int = TaskManager.get_task_state(ui_data["task_id"])
	# don't open if the task is hidden or completed
	if task_state == TaskManager.task_state.HIDDEN or task_state == TaskManager.task_state.COMPLETED:
		return
	#call base_open() in parent class
	.base_open()

#called by self or ui system
func base_close():
	#call base_close() in parent class
	.base_close()
