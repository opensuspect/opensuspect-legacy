tool
extends InteractTask

var target_time: int = 433
var current_time: int = 630

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _init_resource(_from: Node):
	target_time = gen_rand_time()
	current_time = gen_rand_time()

func _gen_task_data() -> Dictionary:
	print("clockset gen task data")
	return {}

func is_complete() -> bool:
	return target_time == current_time

func get_target_time() -> int:
	return target_time

func set_current_time(time: int):
	current_time = time

func get_current_time() -> int:
	return current_time

func gen_rand_time() -> int:
	return normalise_time(randi())

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
