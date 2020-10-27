extends WindowDialog

onready var hoursNode: Node = get_node("clock/hours")
onready var minutesNode: Node = get_node("clock/minutes")
onready var ampmNode: Node = get_node("clock/ampm")

func _ready():
	popup()

func _process(_delta):
	if not visible:
		return
	#so you can't type into the spinboxes
	grab_focus()

func _on_hours_value_changed(value):
	if value == 0:
		hoursNode.value = 12
	if value == 13:
		hoursNode.value = 1

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

func _on_hours_focus_entered():
	print("hours focused")
	hoursNode.release_focus()

func _on_minutes_focus_entered():
	minutesNode.release_focus()

func _on_ampm_focus_entered():
	ampmNode.has_focus()


func _on_hours_focus_exited():
	print("hours unfocused")
