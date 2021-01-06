extends PopupBase

class_name PopupTask

func _ready():
	#warning-ignore:return_value_discarded
	TaskManager.connect("task_completed", self, "_on_task_completed")
	#warning-ignore:return_value_discarded
	TaskManager.connect("receive_task_data", self, "_on_received_task_data")

func complete_task(data: Dictionary = {}):
	var taskInfo = TaskManager.gen_task_info(ui_data["task_id"])
	TaskManager.attempt_complete_task(taskInfo, data)

func _on_task_completed(taskInfo: Dictionary):
	if not TaskManager.is_task_info_valid(taskInfo):
		return
	var taskId = taskInfo[TaskManager.TASK_ID_KEY]
	var playerId = taskInfo[TaskManager.PLAYER_ID_KEY]
	if not TaskManager.is_task_global(taskId):
		if Network.get_my_id() != playerId:
			return
	elif playerId != TaskManager.GLOBAL_TASK_PLAYER_ID:
		return
	# only close the ui if we have completed the task
	if ui_data["task_id"] == taskId:
		base_close()

func _on_received_task_data(task_data: Dictionary):
	var taskId = task_data["task_id"]
	if ui_data["task_id"] != taskId:
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
	var taskId = ui_data["task_id"]
	if not TaskManager.does_task_exist(taskId):
		return
	var playerId = Network.get_my_id()
	if TaskManager.is_task_global(taskId):
		playerId = TaskManager.GLOBAL_TASK_PLAYER_ID
	
	var taskInfo = TaskManager.gen_task_info(taskId, playerId)
	var taskState: int = TaskManager.get_task_state(taskInfo)
	# don't open if the task is hidden
	if taskState == TaskManager.task_state.HIDDEN:
		return
	# or completed
	elif taskState == TaskManager.task_state.COMPLETED:
		return
	# or invalid(means that the task info we provided was invalid)
	elif taskState == TaskManager.task_state.INVALID:
		return
	TaskManager.attempt_request_task_data(taskInfo)
	
	#call base_open() in parent class
	.base_open()

#called by self or ui system
func base_close():
	#call base_close() in parent class
	.base_close()
