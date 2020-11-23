tool
extends Resource

#class_name InteractMap

#name of the UI to open
export(NodePath) var interact_with

export(NodePath) var this_node
#data to pass to the UI node
export(Dictionary) var interact_data

#called to execute the interaction this resource is customized for
func interact():
	MapManager.interact_with(interact_with, this_node, interact_data)

func _init():
	#ensures customizing this resource won't change other resources
	resource_local_to_scene = true

#EDITOR STUFF BELOW THIS POINT, DO NOT TOUCH UNLESS YOU KNOW WHAT YOU'RE DOING
#---------------------------------------------------------------------------------------------------
#overrides set(), allows for export var groups and display properties that don't
#match actual var names
func _set(property, value):
	pass
#	match property:

#overrides get(), allows for export var groups and display properties that don't
#match actual var names
func _get(property):
	pass
#	match property:

#overrides get_property_list(), tells editor to show more vars in inspector
func _get_property_list():
	#if not Engine.editor_hint:
	#	return []
	var property_list: Array = []
	return property_list
