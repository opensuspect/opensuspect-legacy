extends Node
class_name BaseMaintenanceTask

"""
To create a maintenance task:
	1. add a standbutton to the map
	2. instance src/assets/maps/interactables/maintenancetask/maintenancetask.tscn
		as a child of the standbutton
	3. in the standbutton's node editor edit the interact resource
		* set the interact type to map
		* set the interact node to the node you created in step 2.
	4. write a script that inherrits this script, and implement the required methods:
		* update(delta) the only optinal func to inherit. gets called periodicaly to run your task logic
			@delta can be 0.1ms or 2 seconds(in order to preserve bandwidth)
			it is determened by the timer in maintenancetask.tscn
				+ wait time no peers is the update interval(in seconds) when no one on the network has a gui open
				+ wait time peers is the update interwal when at least one person on the network has the gui open
		* these are supposed to be called by your update(delta) when appropriate
		  but I haven't figured out how to properly implement them
		  perhaps the best thing would be to override them for custom behaviour
		  and to call the base class, so the call can propagate to the network
			* output_low
			* output_high
			* output_low_critical
			* output_high_critical
		
		* get_update_gui_dict() -> Dictionary
			@return a dict that your gui script will parse in order to update its contents
		 
		* _handle_input_from_gui(_new_input_data: Dictionary)
			@_new_input_data when the user of your gui clicks some buttons
			this function will get called so you can act upon it.
			You choose what the dict is going to contain in your gui script
			
		* get_gui_name() -> String
			@return a name of your gui, as you specified in the UIManager.ui_list
			so that gui interaction can be abstracted for you.
			Currently, godot fails to export variables to child classes,
			so the guiName variable below can't be used to set the gui name in the inspector.
			I hear that godot 4.0 fixes this, so, when we start using that,
			the get_gui_name() -> String in child classes should be removed
			and the gui name should be supplied in the node editor.
			this script can then use guiName in its get_gui_name() -> String method

================
	5. IMPORTANT Set the just created script as the script for the instanced maintenancetask.tscn
================
	
	6. Create a scene that represents your gui,
		and create a script that inherits BaseMaintenanceTaskGui.
		Override the required methods:
			*update_gui(params: Dictionary)
			@params the parameters that are generated in get_update_gui_dict()
		
			* When the user has changed their input data, call 
			backend.input_from_gui(_new_input_data: Dictionary)
			it handles the networking stuff, and calls the
			_handle_input_from_gui(_new_input_data: Dictionary) method,
			that you overwrote in your child of BaseMaintenanceTask
			
			
------------------------------

So, to create the GasValve task that NiceMicro made:
	1. a) add an empty node on the map(this is so the standbutton becomes visible)
	1. b) instance a standbutton as the child of the empty node added in step 1. a)
	2. instance src/assets/maps/interactables/maintenancetask/maintenancetask.tscn
		as the child of the standbutton
	3. in the standbutton's node editor edit the interact resource
		* set the interact type to map
		* set the interact Map -> interact with to the node you created in step 2.
	4. IMPORTANT: Load the following script:
		src/assets/common/classes/tasks-maintenance/taskgass.gd
		to be the script of the node you created in step 2.
	5. UIManager.ui_list already contains the required entry to activate the gastask ui
		"gasvalve": {"scene": preload("res://assets/ui/tasks/gasvalve/gasvalve.tscn")}
		but when writing your own task, you would add your own tscn and the name
		Here, name is "gasvalve", so the
		BaseMaintenanceTask, BaseMaintenanceTaskGui both suply methods that
		need to be overridden to return
		get_gui_name() -> String that returns "gasvalve"(in this case)
"""
# the name of the gui that should represent this task to the user
# as defined in UIManager.menus
export var guiName: String = "Null"

export var idealOutput = 10.0
export var acceptedRange = 2.0
export var warningRange = 3.0

#The minimum and maximum input with min and max drift velocities
export var inputMinPressure = 0
export var inputMaxPressure = 10
export var inputMaxDrift = 1
export var inputMinDrift = 0.0
export var driftDrift = 0.01
#Possible settings of the dial

export var dialMinValue = 0
export var dialMaxValue = 10.0
export var dialUnit = 0.2
export var outputDrift = 0.2

var frontend

# peers that have opened a gui on their end
var peers = Array()

func register_gui(gui) -> bool:
	# only assign a gui if we don't already have a gui
	if frontend == null:
		frontend = gui
		rpc_id(1, "_register_peer") # tell the server we have opened a gui
			
	# if the gui was previously assigned, the below expression will be false
	return frontend == gui

func unregister_gui(gui):
	if frontend == gui:
		frontend = null
		rpc_id(1, "_unregister_peer") # tell the server we have closed a gui

master func _register_peer():
	# TODO supply peer id as an argument too, as get_tree().get_rpc_sender_id()
	# can get unreliable in certian cases. But dont 100% trust the supplied id,
	# as it could be fake, something like supplied id == peer_id is the best
	var peer_id = get_tree().get_rpc_sender_id()
	if not peers.has(peer_id):
		peers.append(peer_id)
		$Timer.set_has_peers(true)
		
		
master func _unregister_peer():
	peers.erase(get_tree().get_rpc_sender_id())
	if peers.empty():
		# no peers left, no need to waste processing power and network bandwidth
		$Timer.set_has_peers(false)
	
	
var last_timer_fire: float
func _ready():
	set_network_master(1)
	#warning-ignore:return_value_discarded
	MapManager.connect("interacted_with", self, "interacted_with")
	# only the server should start the timer
	if Network.is_network_master():
		# timer is used to save processing power,
		# no need to update tasks every frame
		#warning-ignore:return_value_discarded
		$Timer.connect("timeout", self, "_timer_update")
		

	
func interacted_with(interactNode, _from, _interact_data):
	if interactNode != self:
		return
	UIManager.open_ui(get_gui_name(), {"linkedNode": self})
	
master func input_from_gui(new_input_data: Dictionary):
	if not Network.is_network_master():
		rpc_id(1, "input_from_gui", new_input_data)
		return
	_handle_input_from_gui(new_input_data)
	
"""
The child class calls this method.
This method should display a warning to the user
"""
puppet func output_low():
	if Network.is_network_master():
		rpc("output_low")
	
puppet func output_high():
	if Network.is_network_master():
		rpc("output_high")
	
puppet func output_low_critical():
	if Network.is_network_master():
		rpc("output_low_critical")
		
puppet func output_high_critical():
	if Network.is_network_master():
		rpc("output_high_critical")
	
func _timer_update():
	if not Network.is_network_master():
		return
	var current_time = OS.get_ticks_msec()
	var delta = (current_time - last_timer_fire) / 1000
	last_timer_fire = current_time
	update(delta)
	if not peers.empty():
		rpc("_update_gui", get_update_gui_dict())
	
remotesync func _update_gui(gui_update_dict: Dictionary):
	if frontend != null:
		frontend.update_gui(gui_update_dict)

# All of the logic goes into this method
# the $Timer calls this if we are the server
func update(_delta):
	pass
	#assert(false) # Never can be called on base class
	
func get_update_gui_dict():
	assert(false) # Never can be called on base class
	return {}
# overwrite this method in your implementation
# and make it return the gui name that you specified in UIManager.menus
func get_gui_name() -> String:
	assert(false) # Never can be called on base class
	return guiName
	
func _handle_input_from_gui(_new_input_data: Dictionary):
	assert(false) # Never can be called on base class
	
