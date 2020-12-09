extends BaseMaintenanceTask

var byte0 = [	randi() % 2,
				randi() % 2,
				randi() % 2,
				randi() % 2,
				randi() % 2,
				randi() % 2,
				randi() % 2,
				randi() % 2]
var byte1 = [	randi() % 2,
				randi() % 2,
				randi() % 2,
				randi() % 2,
				randi() % 2,
				randi() % 2,
				randi() % 2,
				randi() % 2]

var answer = [0, 0, 0, 0, 0, 0, 0, 0]
func _ready():
	pass
	
func get_gui_name() -> String:
	return "booleanalgebra"
	
func _handle_input_from_gui(_new_input_data: Dictionary):
	assert(_new_input_data.has("index_to_flip"))
	var i = _new_input_data["index_to_flip"]
	answer[i] = !answer[i]
	
func _get_update_gui_dict() -> Dictionary:
	return {"byte0": byte0, "byte1": byte1, "answer": answer}
