extends BaseMaintenanceTaskGui

signal updateInputGauge
signal updateOutputGauge
signal updateDial

func update_gui(guiParams: Dictionary):
	assert(guiParams.has_all(
		["inputPressureRatio", "outputPressureRatio", "dialRatio"]))
		
		
	emit_signal("updateInputGauge", guiParams["inputPressureRatio"])
	emit_signal("updateOutputGauge", guiParams["outputPressureRatio"])
	emit_signal("updateDial", guiParams["dialRatio"])

func _on_decrease_pressed():
	if backend != null:
		backend.input_from_gui({"direction": -1})

func _on_increase_pressed():
	if backend != null:
		backend.input_from_gui({"direction": +1})
		
func getGuiName() -> String:
	return "gasvalve"

