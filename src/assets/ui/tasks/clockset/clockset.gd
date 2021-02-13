extends WindowDialogTask

onready var hoursNode: Node = get_node("clock/hours")
onready var minutesNode: Node = get_node("clock/minutes")
onready var ampmNode: Node = get_node("clock/ampm")

func _ready():
	hoursNode.get_line_edit().connect("focus_entered", self, "_on_hours_focus_entered")
	minutesNode.get_line_edit().connect("focus_entered", self, "_on_minutes_focus_entered")
	ampmNode.get_line_edit().connect("focus_entered", self, "_on_ampm_focus_entered")

func open():
	ui_data_updated()

func ui_data_updated():
	setClockTime(getCurrentTime())
	setWatchTime(getTargetTime())

func checkComplete():
	updateCurrentTime()
	if get_res().is_complete():
		taskComplete()

func taskComplete():
	.complete_task({"newText": str(getCurrentTime())})

func setClockTime(newTime: int):
# warning-ignore:integer_division
	hoursNode.value = roundDown(newTime / 100, 1)
	minutesNode.value = newTime % 100

func setWatchTime(newTime):
	$watch/watchface.showTime(newTime)

func updateCurrentTime():
	var time = (hoursNode.value * 100) + minutesNode.value
	get_res().set_current_time(time)

func getTargetTime() -> int:
	return get_res().get_target_time()

func getCurrentTime() -> int:
	return get_res().get_current_time()

func get_res() -> Resource:
	return ui_data["resource"]

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
	
# returns a valid time(from 00:00 to 12:59)
# num can be any value
func normalise_time(num: int) -> int:
	num = num % 1259
	num = roundDown(num, 100) + (num % 100) % 60
	if num < 100:
		# this is military time, so can't have values smaller than 100
		num += 1200
	return num
	
func roundDown(num, step) -> int:
	var normRound = stepify(num, step)
	if normRound > num:
		return normRound - step
	return int(normRound)

#so you can't type into the spinboxes
func _on_hours_focus_entered():
	grab_focus()

func _on_minutes_focus_entered():
	grab_focus()

func _on_ampm_focus_entered():
	grab_focus()
