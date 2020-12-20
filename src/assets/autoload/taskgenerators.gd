extends Node

# the task data(eg. currentTime, targetTime) should be set server side
# these generators should generate new data every time they are called
var task_data_generators: Dictionary = {
	"Task system clockset standbutton": funcref(self, "clockset_task_generator"),
	"Task system clockset": funcref(self, "clockset_task_generator")
	}

func call_generator(task_text: String) -> Dictionary:
	assert(task_data_generators.has(task_text))
	assert(task_data_generators[task_text].is_valid())
	return task_data_generators[task_text].call_func()


####clock task
func roundDown(num, step):
	var normRound = stepify(num, step)
	if normRound > num:
		return normRound - step
	return normRound

func clockset_task_generator() -> Dictionary:
	#warning-ignore:narrowing_conversion
	var targetTime: int = round(rand_range(100, 1259))
	targetTime = roundDown(targetTime, 100) + (targetTime % 100) % 60
	var dict = {"currentTime": 630,
				"targetTime": targetTime}
	return dict
	
