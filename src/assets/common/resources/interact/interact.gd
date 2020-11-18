tool
extends Resource

class_name Interact

var interact_type: Resource = load("res://assets/common/resources/taskresources/task/task.tres")

var list_abc = true
var abc = "Script"

func init_task():
	print(abc)

func set_interact(resdir: String):
#	for i in 100:
	interact_type = load(resdir)

func _init():
	pass
	#if Engine.editor_hint:
	#	return
	#interact_type = load("res://assets/common/resources/taskresources/task/task.tres")

#overrides get, allows for export var groups
func _get(property):
	match property:
		"group/subgroup/abc":
			return abc 
		"group/list_abc":
			return list_abc

#overrides set, allows for export var groups
func _set(property, value): # overridden
	#set_interact("res://assets/common/resources/taskresources/task/task.tres")
	#interact_type = load("res://assets/common/resources/taskresources/task/task.tres")
	match property:
		"group/subgroup/abc":
			abc = value
		"group/list_abc":
			list_abc = value  
			#updates inspector
			property_list_changed_notify()
	return true

#overrides _get_property_list, tells editor to show more vars in inspector
func _get_property_list():
	var property_list = []
	property_list.append({
		"name": "interact_type",
		"type": TYPE_OBJECT,
		"usage": PROPERTY_USAGE_DEFAULT,
		"hint": PROPERTY_HINT_RESOURCE_TYPE,
		"hint_string": "TaskInteract",
		})
#	property_list.append({
#		"name": "group/list_abc",
#		"type": TYPE_BOOL,
#		"usage": PROPERTY_USAGE_DEFAULT,
#		"hint": PROPERTY_HINT_NONE,
#		})
#	if list_abc == true:
#		property_list.append({
#		"name": "group/subgroup/abc",
#		"type": TYPE_STRING,
#		"usage": PROPERTY_USAGE_DEFAULT,
#		"hint": PROPERTY_HINT_NONE,
#		"hint_string": "one,two,three",
#		})
	return property_list
