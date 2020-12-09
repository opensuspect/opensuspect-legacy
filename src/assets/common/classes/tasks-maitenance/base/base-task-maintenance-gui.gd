extends WindowDialogBase
class_name BaseMaintenanceTaskGui

var backend: BaseMaintenanceTask = null

# Implement this to receive updates from the backend
func update_gui(params: Dictionary):
	assert(false)
	pass
	
func base_open():
	.base_open()
	if self.ui_data.has("linkedNode"):
		if self.ui_data["linkedNode"] is BaseMaintenanceTask:
			backend = self.ui_data["linkedNode"]
			var registration_successful: bool = backend.register_gui(self)
			if not registration_successful:
				backend = null
				# TODO show an error saying that we failed to link the backend?

# TODO it is important that this gets called so that the server can go into
# low update frequency mode. But it doesn't get called currently
func base_close():
	.base_close()
	UIManager.close_ui(self.getGuiName())
	if backend != null:
		backend.unregister_gui(self)
		backend = null

func _on_gasvalve_about_to_show():
	pass
	
# Instead this gets called out of the blue.. why??
func _on_gasvalve_popup_hide():
	#UIManager.menu_closed(getGuiName())
	if backend != null:
		backend.unregister_gui(self)
		backend = null
	assert(false) #why does this method get called???

# override this in your implementation. the name should be what you
# wrote in UIManager.menus
func getGuiName() -> String:
	assert(false)
	return "null"
