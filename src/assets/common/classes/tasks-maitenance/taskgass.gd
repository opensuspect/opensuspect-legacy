extends BaseMaintenanceTask

var menuData: Dictionary = {}

#variables for the pressure
var inputPressure: float #the pressure coming from the main pipe
var inputPressTarget: float #the input pressure slowly drifts towards this value
var inputDrift: float #the drift velocity of the input pressure
var dial: float #the setting of the pressure valve on the regulator
var outputPressure: float #the regulated pressure provided by the valve



func _ready():
	var initialOutput: float
	
	inputPressure = rand_range(inputMinPressure, inputMaxPressure)
	inputPressTarget = rand_range(inputMinPressure, inputMaxPressure)
	inputDrift = inputMinDrift
	initialOutput = rand_range(idealOutput-warningRange, idealOutput-acceptedRange)
	print("Initial Output: ", initialOutput)
	dial = round((initialOutput - inputPressure) / dialUnit) * dialUnit
	outputPressure = inputPressure + dial
	#emit_signal("updateDial",  dial / (dialMaxValue - dialMinValue))
	print("D=", dial, "; IP=", inputPressure, "; IPT=", inputPressTarget, "; OP=", outputPressure)

	
	
func _handle_input_from_gui(new_input_data: Dictionary):
	if new_input_data != null and not new_input_data.has("direction"):
		print("[Maintenance task::Gas]	_handle_input: bad dictionary provided")
		return
	var direction = new_input_data["direction"]
	assert(direction == -1 or direction == 1)
	dial += dialUnit * direction
	# keep the dial in the desired range
	dial = max(dialMinValue, dial)
	dial = min(dialMaxValue, dial)

func update(delta):
	# this one updates the gas pressures every frame.
	var outPressTarget
	
	# input pressure drifts towards the target pressure in a nonlinear way:
	inputDrift = inputDrift + ((inputMaxDrift-inputDrift) / (inputMaxDrift-inputMinDrift) * driftDrift * delta)
	inputPressure = inputPressure + (inputPressTarget - inputPressure) * inputDrift * delta
	# the current input pressure and dial settings set a target towards which the output pressure drifts:
	outPressTarget = inputPressure + dial
	outputPressure = outputPressure + (outPressTarget - outputPressure) * outputDrift * delta

	# check whether the current pressure is in the approved range and send the proper signals
	if outputPressure < idealOutput - warningRange:
		#the gas pressure is too low, the tasks dependent on gas supply should fail
		output_low()
	elif outputPressure > idealOutput + warningRange:
		# the gas pressure is too high, it could be a fail condution
		output_high()
	elif outputPressure < idealOutput - acceptedRange:
		# the gas pressure reached the warning levels, should send out an alarm
		output_low_critical()
	elif outputPressure > idealOutput + acceptedRange:
		output_high_critical()
	# if the input pressure is relatively close to the target, we select a new target
	if abs(inputPressure - inputPressTarget) < (inputMaxPressure - inputMinPressure) * 0.005:
		inputPressTarget = rand_range(inputMinPressure, inputMaxPressure)
		inputDrift = inputMinDrift
		print("reached target pressure, moving on")
		print("D=", dial, "; IP=", inputPressure, "; IPT=", inputPressTarget, "; OP=", outputPressure)

func get_update_gui_dict():
	var guiInput = (inputPressure - inputMinPressure) / (inputMaxPressure - inputMinPressure)
	var guiOutput = (outputPressure - idealOutput) / (warningRange * 2 + 2) + 0.5
	var dialOutput = dial / (dialMaxValue - dialMinValue)
	return {"inputPressureRatio": guiInput,
			"outputPressureRatio": guiOutput,
			"dialRatio": dialOutput}
			
func get_gui_name() -> String:
	return "gasvalve"
	
