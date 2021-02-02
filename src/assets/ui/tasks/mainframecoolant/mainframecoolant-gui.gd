extends BaseMaintenanceTaskGui

onready var fanOptionList: ItemList = $FanSetting/ItemList
onready var tempDisplay: Label = $CurrentTemp/Temp
onready var tempProgress: ProgressBar = $CurrentTemp/ProgressBar
# item at 0 causes the heat to build up(quickly)
# item at 1 causes the heat to stay at it's current level
# item at 2 causes the heat to dissipate(slowly)
var options 		= ["Idle", "Normal", "High"]
var optionValues	= [10, 		0,			-7]
func _ready():
	for item in options:
		fanOptionList.add_item(item)
	fanOptionList.connect("item_activated", self, "_on_item_activated")
		
func _on_item_activated(index:int):
	var multiplier = optionValues[index]
	self.send_input_to_backend({"HeatDispersionMultiplier": multiplier})
	
func update_gui(params: Dictionary):
	assert(params.has("temp") and params["temp"] is float)
	tempDisplay.set_text(String(params["temp"]))
	tempProgress.set_value(params["temp"])
