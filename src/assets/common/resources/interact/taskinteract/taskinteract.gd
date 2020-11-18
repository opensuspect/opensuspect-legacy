tool
extends Resource

class_name TaskInteract

export(String) var task_name

var item_inputs_on: bool
var item_inputs: PoolStringArray

var item_outputs_on: bool
var item_outputs: PoolStringArray

var list_abc = true
var abc = "Script"

func init_task():
	print(abc)

func _init():
	if Engine.editor_hint:
		
		return
	print(abc)

#overrides get, allows for export var groups
func _get(property):
	match property:
		"inputs/toggle_items":
			return item_inputs_on
		"inputs/input_items":
			return item_inputs

		"outputs/toggle_items":
			return item_outputs_on
		"outputs/output_items":
			return item_outputs

		"group/subgroup/abc":
			return abc 
		"group/list_abc":
			return list_abc

#overrides set, allows for export var groups
func _set(property, value): # overridden
	match property:
		"inputs/toggle_items":
			item_inputs_on = value
			property_list_changed_notify()
		"inputs/input_items":
			item_inputs = value

		"outputs/toggle_items":
			item_outputs_on = value
			property_list_changed_notify()
		"outputs/input_items":
			item_outputs = value

		"group/subgroup/abc":
			abc = value
		"group/list_abc":
			list_abc = value
			property_list_changed_notify()
	return true

#overrides _get_property_list, tells editor to show more vars in inspector
func _get_property_list():
	var property_list = []
	property_list.append({
		"name": "inputs/toggle_items",
		"type": TYPE_BOOL,
		"usage": PROPERTY_USAGE_DEFAULT,
		"hint": PROPERTY_HINT_NONE,
		})
	if item_inputs_on:
		property_list.append({
		"name": "inputs/input_items",
		"type": TYPE_STRING_ARRAY,
		"usage": PROPERTY_USAGE_DEFAULT,
		"hint": PROPERTY_HINT_NONE,
		})
	
	property_list.append({
		"name": "outputs/toggle_items",
		"type": TYPE_BOOL,
		"usage": PROPERTY_USAGE_DEFAULT,
		"hint": PROPERTY_HINT_NONE,
		})
	if item_outputs_on:
		property_list.append({
		"name": "outputs/output_items",
		"type": TYPE_STRING_ARRAY,
		"usage": PROPERTY_USAGE_DEFAULT,
		"hint": PROPERTY_HINT_NONE,
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
