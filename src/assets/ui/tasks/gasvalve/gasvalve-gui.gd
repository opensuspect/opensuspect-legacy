extends BaseMaintenanceTaskGui

signal updateInputGauge
signal updateOutputGauge
signal updateDial

signal updateOutputMax
signal updateOutputMin

func update_gui(guiParams: Dictionary):
	assert(guiParams.has_all(
		[	"inputPressureRatio", "outputPressureRatio", "dialRatio",
			"minAcceptedRange", "maxAcceptedRange"]))
		
	emit_signal("updateInputGauge", guiParams["inputPressureRatio"])
	emit_signal("updateOutputGauge", guiParams["outputPressureRatio"])
	emit_signal("updateDial", guiParams["dialRatio"])
	
	emit_signal("updateOutputMin", guiParams["minAcceptedRange"])
	emit_signal("updateOutputMax", guiParams["maxAcceptedRange"])

func _on_decrease_pressed():
	self.send_input_to_backend({"direction": -1})

func _on_increase_pressed():
	self.send_input_to_backend({"direction": +1})
		
