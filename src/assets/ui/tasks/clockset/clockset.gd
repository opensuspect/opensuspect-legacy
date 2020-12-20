extends WindowDialogTask

#var ui_data: Dictionary = {}
var targetTime: int = 433
var currentTime: int = 630

onready var hoursNode: Node = get_node("clock/hours")
onready var minutesNode: Node = get_node("clock/minutes")
onready var ampmNode: Node = get_node("clock/ampm")

func _ready():
	hoursNode.get_line_edit().connect("focus_entered", self, "_on_hours_focus_entered")
	minutesNode.get_line_edit().connect("focus_entered", self, "_on_minutes_focus_entered")
	ampmNode.get_line_edit().connect("focus_entered", self, "_on_ampm_focus_entered")

func open():
# warning-ignore:narrowing_conversion
	
	ui_data_updated()

#func close():
#	pass
func ui_data_updated():
	if ui_data.has("currentTime"):
		currentTime = ui_data["currentTime"]
	if ui_data.has("targetTime"):
		targetTime = ui_data["targetTime"]
	setClockTime(currentTime)
	setWatchTime(targetTime)
		
func checkComplete():
	updateCurrentTime()
	if currentTime == targetTime:
		taskComplete()

func taskComplete():
	#theoretically this is where it would hook into the task manager
	#gotcha!
	#PlayerManager.assignedtasks[0] = 1
#	print("clockset task complete")
#	if ui_data.keys().has("linkedNode"):
#		MapManager.interact_with(ui_data["linkedNode"], self, {"newText": str(currentTime)})
	.complete_task({"newText": str(currentTime)})
	#hide()

func setClockTime(newTime):
	hoursNode.value = TaskGenerators.roundDown(newTime / 100, 1)
	minutesNode.value = newTime % 100

func setWatchTime(newTime):
	$watch/watchface.showTime(newTime)

func updateCurrentTime():
	currentTime = (hoursNode.value * 100) + minutesNode.value

func _on_hours_value_changed(value):
	if value == 0:
		hoursNode.value = 12
	if value == 13:
		hoursNode.value = 1
	checkComplete()

func _on_minutes_value_changed(value):
	if value == -1:
		minutesNode.value = 59
		value = 59
	if value == 60:
		minutesNode.value = 0
		value = 0
	if value < 10:
		minutesNode.prefix = "0" + str(value) + "       "
	else:
		minutesNode.prefix = ""
	checkComplete()

func _on_ampm_value_changed(value):
	#allowing rollover
	if value == -1:
		ampmNode.value = 1
		value = 1
	if value == 2:
		ampmNode.value = 0
		value = 0
	#making it show AM or PM
	if value == 0:
		 #added spaces so the number doesn't show up in spinbox
		ampmNode.prefix = "AM" + "     "
	else:
		#added spaces so the number doesn't show up in spinbox
		ampmNode.prefix = "PM" + "     "
	checkComplete()

#so you can't type into the spinboxes
func _on_hours_focus_entered():
	grab_focus()

func _on_minutes_focus_entered():
	grab_focus()

func _on_ampm_focus_entered():
	grab_focus()
