extends BaseMaintenanceTask

# do we use celsius or F, maybe K is a universal choice?
export var idealTemp: float = 45.0
export var maxTemp: float = 105.0
export var warnTemp: float = 85.0
export var heatBuildup: float = 0.2

var currentTemp = idealTemp
var multiplier = 0

func update(delta):
	currentTemp += (heatBuildup * multiplier) * delta
	# don't go below the ideal temp
	if currentTemp < idealTemp and multiplier < 0:
		multiplier = 0
	if currentTemp > warnTemp:
		output_high() 
	if currentTemp > maxTemp and multiplier > 0:
		output_high_critical()
		
func get_update_gui_dict():
	return {"temp": currentTemp}
	
func _handle_input_from_gui(_new_input_data: Dictionary):
	assert(_new_input_data.has("HeatDispersionMultiplier"))
	var mp = _new_input_data["HeatDispersionMultiplier"]
	assert(multiplier is int or multiplier is float)
	multiplier = mp
	
func is_complete(player_id):
	return currentTemp < warnTemp
