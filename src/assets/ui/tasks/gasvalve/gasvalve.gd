extends BaseMaintenanceTask

var menuData: Dictionary = {}

#variables for the pressure
var inputPressure: float #the pressure coming from the main pipe
var inputPressTarget: float #the input pressure slowly drifts towards this value
var inputDrift: float #the drift velocity of the input pressure
var dial: float #the setting of the pressure valve on the regulator
var outputPressure: float #the regulated pressure provided by the valve

var idealOutput:int

export var acceptedRange = 2.0
export var warningRange = 3.0

#The minimum and maximum input with min and max drift velocities
export var inputMinPressure = 0
export var inputMaxPressure = 10
export var inputMaxDrift = 1
export var inputMinDrift = 0.0
export var driftDrift = 0.01
#Possible settings of the dial

export var dialMinValue = 0
export var dialMaxValue = 10.0
export var dialUnit = 0.2
export var outputDrift = 0.2

func _ready():
	var initialOutput: float
	
	idealOutput = rand_range(inputMinPressure, inputMaxPressure)
	inputPressure = rand_range(inputMinPressure, inputMaxPressure)
	inputPressTarget = rand_range(inputMinPressure, inputMaxPressure)
	inputDrift = inputMinDrift
	initialOutput = rand_range(idealOutput-warningRange, idealOutput-acceptedRange)
	dial = round((initialOutput - inputPressure) / dialUnit) * dialUnit
	outputPressure = inputPressure + dial
	
	
	
func _handle_input_from_gui(new_input_data: Dictionary):
	assert(new_input_data != null and new_input_data.has("direction"))
	
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

func get_update_gui_dict():
	var guiInput = (inputPressure - inputMinPressure) / (inputMaxPressure - inputMinPressure)
	var guiOutput = (outputPressure - idealOutput) / (warningRange * 2 + 2) + 0.5
	var dialOutput = dial / (dialMaxValue - dialMinValue)
	
	var minAcceptedRange = ((idealOutput - acceptedRange) - inputMinPressure) / (inputMaxPressure - inputMinPressure)
	var maxAcceptedRange = ((idealOutput + acceptedRange) - inputMinPressure) / (inputMaxPressure - inputMinPressure)
	
	return {"inputPressureRatio": guiInput,
			"outputPressureRatio": guiOutput,
			"dialRatio": dialOutput,
			"minAcceptedRange": minAcceptedRange,
			"maxAcceptedRange": maxAcceptedRange}

# returns true if the output is in between idealOutput +- acceptedRange
func is_complete(_playerId) -> bool:
	var upperBound = outputPressure < (idealOutput + acceptedRange)
	var lowerBound = outputPressure > (idealOutput - acceptedRange)
	return upperBound and lowerBound
	
