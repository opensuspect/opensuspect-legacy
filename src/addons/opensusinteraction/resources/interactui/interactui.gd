tool
extends Resource

#class_name InteractUI

#name of the UI to open
export(String) var ui_name
#data to pass to the UI node
export(Dictionary) var ui_data

#changed in the editor via overriding get(), set(), and get_property_list()
#whether or not to delete and recreate the UI node before opening
var reinstance: bool = false

#called to execute the interaction this resource is customized for
func interact():
	UIManager.open_menu(ui_name, ui_data, reinstance)

func _init():
	#ensures customizing this resource won't change other resources
	resource_local_to_scene = true

#EDITOR STUFF BELOW THIS POINT, DO NOT TOUCH UNLESS YOU KNOW WHAT YOU'RE DOING
#---------------------------------------------------------------------------------------------------
#overrides set(), allows for export var groups and display properties that don't
#match actual var names
func _set(property, value):
	match property:
		"advanced/reinstance":
			reinstance = value

#overrides get(), allows for export var groups and display properties that don't
#match actual var names
func _get(property):
	match property:
		"advanced/reinstance":
			return reinstance

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
	return property_list
