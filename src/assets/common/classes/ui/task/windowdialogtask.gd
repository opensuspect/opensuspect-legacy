extends WindowDialogBase

class_name WindowDialogTask

func _ready():
	#warning-ignore:return_value_discarded
	TaskManager.connect("task_completed", self, "_on_task_completed")
	#warning-ignore:return_value_discarded
	TaskManager.connect("receive_task_data", self, "_on_received_task_data")

func complete_task(data: Dictionary = {}):
	var task_info = {	TaskManager.PLAYER_ID_KEY: Network.get_my_id(),
						TaskManager.TASK_ID_KEY: ui_data["task_id"]}
	TaskManager.attempt_complete_task(task_info, data)

func _on_task_completed(task_info: Dictionary):
	if not TaskManager.is_task_info_valid(task_info):
		return
	var task_id = task_info[TaskManager.TASK_ID_KEY]
	var player_id = task_info[TaskManager.PLAYER_ID_KEY]
	if not TaskManager.is_task_global(task_id):
		if Network.get_my_id() != player_id:
			return
	elif player_id != TaskManager.GLOBAL_TASK_PLAYER_ID:
		return
	# only close the ui if we have completed the task
	if ui_data["task_id"] == task_id:
		base_close()

func _on_received_task_data(task_data: Dictionary):
	var task_id = task_data["task_id"]
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
		player_id = TaskManager.GLOBAL_TASK_PLAYER_ID
	var task_info = {	TaskManager.TASK_ID_KEY: task_id,
						TaskManager.PLAYER_ID_KEY: player_id}
	var task_state: int = TaskManager.get_task_state(task_info)
	# don't open if the task is hidden
	if task_state == TaskManager.task_state.HIDDEN:
		return
	# or completed
	elif task_state == TaskManager.task_state.COMPLETED:
		return
	# or invalid(means that the task info we provided was invalid)
	elif task_state == TaskManager.task_state.INVALID:
		return
	TaskManager.attempt_request_task_data(task_info)
	
	#call base_open() in parent class
	.base_open()

#called by self or ui system
func base_close():
	#call base_close() in parent class
	.base_close()
