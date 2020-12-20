extends WindowDialogBase

class_name WindowDialogTask

func _ready():
	#warning-ignore:return_value_discarded
	TaskManager.connect("task_completed", self, "_on_task_completed")
	#warning-ignore:return_value_discarded
	TaskManager.connect("receive_task_data", self, "_on_received_task_data")

func complete_task(data: Dictionary = {}):
	TaskManager.rpc_id(1, 	"complete_task_remote", ui_data["task_text"],
							Network.get_my_id(), data)

func _on_task_completed(task_id: int, player_id: int):
	if not TaskManager.is_task_global(task_id):
		if Network.get_my_id() != player_id:
			return
	elif player_id != TaskManager.GLOBAL_TASK_ID:
		return
	# only close the ui if we have completed the task
	if ui_data["task_id"] == task_id:
		base_close()

func _on_received_task_data(task_id: int, task_data: Dictionary):
	if ui_data["task_id"] != task_id:
		return
	for key in task_data.keys():
		ui_data[key] = task_data[key]
	ui_data_updated()
		
#called when the server sends the ui data of this task
func ui_data_updated():
	assert(false) #override in base class
	return
#called by ui system
func base_open():
	if not ui_data.keys().has("task_id"):
		return
	var task_id = ui_data["task_id"]
	if not TaskManager.does_task_exist(task_id):
		return
	var player_id = Network.get_my_id()
	if TaskManager.is_task_global(task_id):
		player_id = TaskManager.GLOBAL_TASK_ID
	var task_state: int = TaskManager.get_task_state(task_id, player_id)
	# don't open if the task is hidden or completed
	if task_state == TaskManager.task_state.HIDDEN or task_state == TaskManager.task_state.COMPLETED:
		return
	TaskManager.rpc_id(1, "request_task_data", ui_data["task_text"], Network.get_my_id())
	
	#call base_open() in parent class
	.base_open()

#called by self or ui system
func base_close():
	#call base_close() in parent class
	.base_close()
