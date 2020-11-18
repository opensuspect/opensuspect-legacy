#tool
extends Resource

#SHOULD NOT BE USED

class_name Interact

enum type {task, ui, map}
export(type) var interact_type = type.task
var interact_res: Resource# = load("res://assets/common/resources/interact/taskinteract/taskinteract.tres")

var list_abc = true
var abc = "InteractScript"

func init_task():
	pass
#	print(abc)

func set_interact(resdir: String):
#	for i in 100:
	interact_res = load(resdir)

func _init():
	#print(str(ClassDB.get_class_list()).replace("[", "").replace("]", "").replace(" ", ""))
	resource_local_to_scene = true
	pass
	#if Engine.editor_hint:
	#	return
	#interact_type = load("res://assets/common/resources/interact/taskinteract/taskinteract.tres")

#overrides get, allows for export var groups
func _get(property):
	if not Engine.editor_hint:
		return []
	match property:
		"group/subgroup/abc":
			return abc 
		"group/list_abc":
			return list_abc

#overrides set, allows for export var groups
func _set(property, value): # overridden
	#set_interact("res://assets/common/resources/interact/taskinteract/taskinteract.tres")
	interact_res = load("res://assets/common/resources/interact/taskinteract/taskinteract.tres")
	if not Engine.editor_hint:
		return []
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
	if not Engine.editor_hint:
		return []
	var class_list = str(ClassDB.get_class_list()).replace("[", "").replace("]", "").replace(" ", "")
	var property_list = []
	var load_TaskInteract_class: String = TaskInteract.resource_path
	property_list.append({
		"name": "interact_type",
		"type": TYPE_OBJECT,
		"usage": PROPERTY_USAGE_DEFAULT,
		"hint": PROPERTY_HINT_RESOURCE_TYPE,
		#don't how to have it not spit "Cannot get class 'TaskInteract'.
		"hint_string": "TaskInteract",# if ClassDB.class_exists("TaskInteract") else class_list,
		})

	property_list.append({
		"name": "group/list_abc",
		"type": TYPE_BOOL,
		"usage": PROPERTY_USAGE_DEFAULT,
		"hint": PROPERTY_HINT_NONE,
		})
	if list_abc == true:
		property_list.append({
		"name": "group/subgroup/abc",
		"type": TYPE_STRING,
		"usage": PROPERTY_USAGE_DEFAULT,
		"hint": PROPERTY_HINT_NONE,
		"hint_string": "one,two,three",
		})
	return property_list
