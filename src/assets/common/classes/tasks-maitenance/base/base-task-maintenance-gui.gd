extends WindowDialogBase
class_name BaseMaintenanceTaskGui

var backend: BaseMaintenanceTask = null

func _ready():
	# warning-ignore:return_value_discarded
	self.connect("popup_hide", self, "_on_popup_hide")
	assert(UIManager.is_ui_name_valid(self.name))

func _on_popup_hide():
	# depends on the node name being the same as the name in UIManager.ui_list
	UIManager.close_ui(self.name)
	
	
# Implement this to receive updates from the backend
# warning-ignore:unused_argument
func update_gui(params: Dictionary):
	assert(false)
	pass
	
# abstract the interaction with the backend
func send_input_to_backend(params: Dictionary):
	if backend != null:
		backend.input_from_gui(params)
	
func base_open():
	.base_open()
	
	if not self.ui_data.has("linkedNode"):
		return
		
	if not self.ui_data["linkedNode"] is BaseMaintenanceTask:
		return
		
	backend = self.ui_data["linkedNode"]
	var registration_successful: bool = backend.register_gui(self)
	if not registration_successful:
		assert(false)
		backend = null

func base_close():
	.base_close()
	if backend != null:
		backend.unregister_gui(self)
		backend = null

