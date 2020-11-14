extends WindowDialog

var menuData: Dictionary = {}

#variables for the pressure
var inputPressure: float #the pressure coming from the main pipe
var inputPressTarget: float #the input pressure slowly drifts towards this value
var inputDrift: float #the drift velocity of the input pressure
var dial: float #the setting of the pressure valve on the regulator
var outputPressure: float #the regulated pressure provided by the valve

#signals for handling the extreme pressures
signal gasPressureWarning #an alarm should go off
signal gasPressureLow #tasks dependent on gas fail
signal gasPressureHigh #tasks dependent on gas fail OR lose condition?

signal updateInputGauge
signal updateOutputGauge
signal updateDial

#The minimum and maximum input pressure with min and max drift velocities
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
#Output ranges
export var idealOutput = 10.0
export var acceptedRange = 2.0
export var warningRange = 3.0


func _ready():
	var initialOutput: float
	
	inputPressure = rand_range(inputMinPressure, inputMaxPressure)
	inputPressTarget = rand_range(inputMinPressure, inputMaxPressure)
	inputDrift = inputMinDrift
	initialOutput = rand_range(idealOutput-warningRange, idealOutput-acceptedRange)
	print("Initial Output: ", initialOutput)
	dial = round((initialOutput - inputPressure) / dialUnit) * dialUnit
	outputPressure = inputPressure + dial
	emit_signal("updateDial",  dial / (dialMaxValue - dialMinValue))
	print("D=", dial, "; IP=", inputPressure, "; IPT=", inputPressTarget, "; OP=", outputPressure)
	

func _process(delta):
	#this one updates the gas pressures every frame.
	var outPressTarget
	
	#input pressure drifts towards the target pressure in a nonlinear way:
	inputDrift = inputDrift + ((inputMaxDrift-inputDrift) / (inputMaxDrift-inputMinDrift) * driftDrift * delta)
	inputPressure = inputPressure + (inputPressTarget - inputPressure) * inputDrift * delta
	emit_signal("updateInputGauge", (inputPressure - inputMinPressure) / (inputMaxPressure - inputMinPressure))
	
	#the current input pressure and dial settings set a target towards which the output pressure drifts:
	outPressTarget = inputPressure + dial
	outputPressure = outputPressure + (outPressTarget - outputPressure) * outputDrift * delta
	emit_signal("updateOutputGauge", (outputPressure - idealOutput) / (warningRange * 2 + 2) + 0.5)
	
	#check whether the current pressure is in the approved range and send the proper signals
	if outputPressure < idealOutput - warningRange:
		#the gas pressure is too low, the tasks dependent on gas supply should fail
		emit_signal("gasPressureLow")
	elif outputPressure > idealOutput + warningRange:
		#the gas pressure is too high, it could be a fail condution
		emit_signal("gasPressureHigh")
	elif outputPressure < idealOutput - acceptedRange or outputPressure > idealOutput + acceptedRange:
		#the gas pressure reached the warning levels, should send out an alarm
		emit_signal("gasPressureWarning")
	
	#if the input pressure is relatively close to the target, we select a new target
	if abs(inputPressure - inputPressTarget) < (inputMaxPressure - inputMinPressure) * 0.005:
		inputPressTarget = rand_range(inputMinPressure, inputMaxPressure)
		inputDrift = inputMinDrift
		print("reached target pressure, moving on")
		print("D=", dial, "; IP=", inputPressure, "; IPT=", inputPressTarget, "; OP=", outputPressure)

func open():
	popup()
	UIManager.menu_opened("gasvalve")

func close():
	hide()
	UIManager.menu_closed("gasvalve")

func _on_gasvalve_about_to_show():
	pass

func _on_gasvalve_popup_hide():
	UIManager.menu_closed("gasvalve")

func _on_decrease_pressed():
	dial -= dialUnit
	dial = max(dialMinValue, dial)
	emit_signal("updateDial", dial / (dialMaxValue - dialMinValue))
	print("D=", dial, "; IP=", inputPressure, "; IPT=", inputPressTarget, "; OP=", outputPressure)

func _on_increase_pressed():
	dial += dialUnit
	dial = min(dialMaxValue, dial)
	emit_signal("updateDial", dial / (dialMaxValue - dialMinValue))
	print("D=", dial, "; IP=", inputPressure, "; IPT=", inputPressTarget, "; OP=", outputPressure)

