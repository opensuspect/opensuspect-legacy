tool
extends Resource

#class_name InteractUI

#name of the UI to open
export(String) var ui_name
#data to pass to the UI node
export(Dictionary) var ui_data

enum actions {OPEN, INSTANCE, UPDATE, CLOSE}
export(actions) var action

#changed in the editor via overriding get(), set(), and get_property_list()
#whether or not to delete and recreate the UI node before opening
var reinstance: bool = false

var free_on_close: bool = false

var interact_data: Dictionary = {}

#called to execute the interaction this resource is customized for
func interact(_from: Node = null, _interact_data: Dictionary = {}):
	match action:
		actions.OPEN:
			open(_from, _interact_data)
		actions.INSTANCE:
			instance(_from, _interact_data)
		actions.UPDATE:
			update(_from, _interact_data)
		actions.CLOSE:
			close()

func open(_from: Node = null, _interact_data: Dictionary = {}, reinstance: bool = self.reinstance):
	UIManager.open_ui(ui_name, get_interact_data(_from, _interact_data), reinstance)

func instance(_from: Node = null, _interact_data: Dictionary = {}):
	UIManager.instance_ui(ui_name, get_interact_data(_from, _interact_data))

func update(_from: Node = null, _interact_data: Dictionary = {}):
	UIManager.update_ui(ui_name, get_interact_data(_from, _interact_data))

func close(free: bool = free_on_close):
	UIManager.close_ui(ui_name, free)

func init_resource(_from: Node = null):
	pass

func get_interact_data(_from: Node = null, interact_data: Dictionary = {}) -> Dictionary:
	var reported_interact_data = interact_data
	for i in ui_data.keys():
		reported_interact_data[i] = ui_data[i]
	for i in interact_data.keys():
		reported_interact_data[i] = interact_data[i]
	#ui interact type is 1
	reported_interact_data["interact_type"] = 1
	reported_interact_data["interact"] = ui_name
	#print(reported_interact_data)
	return reported_interact_data

func _init():
	#ensures customizing this resource won't change other resources
	if Engine.editor_hint:
		#print("interactUI init")
		resource_local_to_scene = true

#EDITOR STUFF BELOW THIS POINT, DO NOT TOUCH UNLESS YOU KNOW WHAT YOU'RE DOING
#---------------------------------------------------------------------------------------------------
#overrides set(), allows for export var groups and display properties that don't
#match actual var names
func _set(property, value):
	match property:
		"advanced/reinstance":
			reinstance = value
		"advanced/free_on_close":
			free_on_close = value

#overrides get(), allows for export var groups and display properties that don't
#match actual var names
func _get(property):
	match property:
		"advanced/reinstance":
			return reinstance
		"advanced/free_on_close":
			return free_on_close

#overrides get_property_list(), tells editor to show more vars in inspector
func _get_property_list():
	#if not Engine.editor_hint:
	#	return []
	var property_list: Array = []
	property_list.append({"name": "advanced/reinstance",
		"type": TYPE_BOOL,
		"usage": PROPERTY_USAGE_DEFAULT,
		"hint": PROPERTY_HINT_NONE,
		})
	property_list.append({"name": "advanced/free_on_close",
		"type": TYPE_BOOL,
		"usage": PROPERTY_USAGE_DEFAULT,
		"hint": PROPERTY_HINT_NONE,
		})
	return property_list
