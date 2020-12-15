extends WindowDialogBase

class_name WindowDialogTask
func _ready():
	TaskManager.connect("task_completed", self, "_on_task_completed")
	
func complete_task(data: Dictionary = {}):
	TaskManager.rpc_id(1, "complete_task_remote", ui_data["task_id"], Network.get_my_id(), data)

func _on_task_completed(task_id: int):
	if ui_data["task_id"] == task_id:
		base_close()

#called by ui system
func base_open():
	if not ui_data.keys().has("task_id"):
		return
	var task_id = ui_data["task_id"]
	if not TaskManager.does_task_exist(task_id):
		return
	var task_state: int = TaskManager.get_task_state(task_id)
	# don't open if the task is hidden or completed
	if task_state == TaskManager.task_state.HIDDEN or task_state == TaskManager.task_state.COMPLETED:
		return
	#call base_open() in parent class
	.base_open()

#called by self or ui system
func base_close():
	#call base_close() in parent class
	.base_close()
