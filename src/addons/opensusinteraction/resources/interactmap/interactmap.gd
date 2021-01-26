tool
extends Resource

#class_name InteractMap

#name of the UI to open
export(NodePath) var interact_with

#export(NodePath) 
var attached_to: Node
#data to pass to the UI node
export(Dictionary) var interact_data

var network_sync: bool = false

var reported_interact_data: Dictionary = {}

#called to execute the interaction this resource is customized for
func interact(_from: Node, _interact_data: Dictionary = {}):
	if attached_to == null and _from != null:
		attached_to = _from
	if attached_to == null:
		push_error("InteractMap resource trying to be used with no defined node")
		return
	#print("InteractMap attached_to: ", attached_to)
	#print(attached_to.get_node(interact_with))
	MapManager.interact_with(attached_to.get_node(interact_with), attached_to, _interact_data, network_sync)

func init_resource(_from: Node, interact_data: Dictionary = {}):
	if attached_to == null and _from != null:
		attached_to = _from
	if attached_to == null:
		push_error("InteractMap resource trying to be initiated with no defined node")

func get_interact_data(_from: Node = null, _interact_data: Dictionary = {}) -> Dictionary:
	if attached_to == null and _from != null:
		attached_to = _from
	if attached_to == null:
		push_error("InteractMap resource trying to be used with no defined node")
	var reported_interact_data = interact_data
	for i in interact_data.keys():
		reported_interact_data[i] = interact_data[i]
	for i in _interact_data.keys():
		reported_interact_data[i] = _interact_data[i]
	#map interact type is 2
	reported_interact_data["interact_type"] = 2
	if attached_to != null:
		reported_interact_data["interact"] = attached_to.get_node(interact_with)
	else:
		reported_interact_data["interact"] = null
	reported_interact_data["from_node"] = attached_to
	return reported_interact_data

func _init():
	#ensures customizing this resource won't change other resources
	if Engine.editor_hint:
		#print("init InteractMap")
		resource_local_to_scene = true

#EDITOR STUFF BELOW THIS POINT, DO NOT TOUCH UNLESS YOU KNOW WHAT YOU'RE DOING
#---------------------------------------------------------------------------------------------------
#overrides set(), allows for export var groups and display properties that don't
#match actual var names
func _set(property, value):
	pass
	match property:
		"advanced/network_sync":
			network_sync = value

#overrides get(), allows for export var groups and display properties that don't
#match actual var names
func _get(property):
	pass
	match property:
		"advanced/network_sync":
			return network_sync

#overrides get_property_list(), tells editor to show more vars in inspector
func _get_property_list():
	#if not Engine.editor_hint:
	#	return []
	var property_list: Array = []
	property_list.append({"name": "advanced/network_sync",
		"type": TYPE_BOOL,
		"usage": PROPERTY_USAGE_DEFAULT,
		"hint": PROPERTY_HINT_NONE,
		})
	return property_list
