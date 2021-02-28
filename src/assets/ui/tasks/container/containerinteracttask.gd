tool
extends InteractTask




func _ready():
	pass 

func _interact(_from: Node = null, _interact_data: Dictionary = {}):
	var dic = Helpers.merge_dicts(_interact_data, get_task_data())
	ui_res.interact(_from, dic)
	return false
