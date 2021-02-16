tool
extends InteractTask

var target_time: int = 433
var current_time: int = 630

signal times_updated(target, current, task_res)

func _init():
	add_networked_func("receive_times", MultiplayerAPI.RPC_MODE_REMOTE)

func _init_resource(_from: Node):
	target_time = gen_rand_time()
	current_time = gen_rand_time()
	emit_signal("times_updated", target_time, current_time, self)

func _gen_task_data() -> Dictionary:
	var data: Dictionary = {}
	data["target_time"] = target_time
	data["current_time"] = current_time
	return data

func _registered(_new_task_id: int, new_task_data: Dictionary):
	# calling is_network_server() on task manager because the function does not
	# 	exist in resources
	if TaskManager.get_tree().is_network_server():
		return
	for property in ["target_time", "current_time"]:
		if new_task_data.has(property):
			set(property, new_task_data[property])

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

func _sync_task():
	send_times(target_time, current_time)

func send_times(target: int, current: int):
	print("sending times out to network")
	task_rpc("receive_times", [target, current])

func receive_times(target: int, current: int):
	print("received times, target: ", target, " current: ", current)
	target_time = target
	current_time = current
	emit_signal("times_updated", target_time, current_time, self)

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
