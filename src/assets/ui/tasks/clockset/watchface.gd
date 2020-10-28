extends Node2D

var currentTime: int = 1300

func _enter_tree():
	showTime(currentTime)

func showTime(newTime: int):
	if not get_node("minuteHand") or not get_node("hourHand"):
		return
	setHourHand(newTime)
	setMinuteHand(newTime)

func setHourHand(newTime: int):
	var newAngle: float = 30 * roundDown(float(newTime) / 100, 1)
	#newAngle = 30 * roundDown(newTime / 100, 1)
	newAngle += 30 * float(newTime % 100) / 60
	#correcting because godot measures from horizontal
	newAngle -= 90
	$hourHand.rotation_degrees = newAngle

func setMinuteHand(newTime: int):
	var newAngle: float = 360 * float(newTime % 100) / 60
	
	#correcting because godot measures from horizontal
	newAngle -= 90
	$minuteHand.rotation_degrees = newAngle

func roundDown(num, step):
	var normRound = stepify(num, step)
	if normRound > num:
		return normRound - step
	return normRound
