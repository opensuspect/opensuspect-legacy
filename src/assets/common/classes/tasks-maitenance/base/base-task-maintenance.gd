extends Node
class_name BaseMaintenanceTask


#To create a maintenance task:
#	1. write a script that inherrits this script, and implement the required methods:
#		* update(delta) the only optinal func to inherit. gets called periodicaly to run your task logic
#			@delta can be 0.1ms or 2 seconds(in order to preserve bandwidth)
#			it is determened by the timer in maintenancetask.tscn
#				+ wait time no peers is the update interval(in seconds) when no one on the network has a gui open
#				+ wait time peers is the update interwal when at least one person on the network has the gui open
#		* these are supposed to be called by your update(delta) when appropriate
#		  but I haven't figured out how to properly implement them
#		  perhaps the best thing would be to override them for custom behaviour
#		  and to call the base class, so the call can propagate to the network
#			* output_low
#			* output_high
#			* output_low_critical
#			* output_high_critical
#		
#		* get_update_gui_dict() -> Dictionary
#			@return a dict that your gui script will parse in order to update its contents
#		 
#		* _handle_input_from_gui(_new_input_data: Dictionary)
#			@_new_input_data when the user of your gui clicks some buttons
#			this function will get called so you can act upon it.
#			You choose what the dict is going to contain in your gui script
#================
#	2. IMPORTANT instance child scene 
#		assets/common/classes/tasks-maintenance/maintenancetask.tscn
#		Set the script that inherited this script(that you wrote)
#		as the script for the instanced maintenancetask.tscn
#				 
#		* make sure to move the instanced scene away from 0,0 coordinate,
#		  otherwise, it will open when the game starts 
#================
#	
#	3. Create a scene that represents your gui,
#		and create a script that inherits BaseMaintenanceTaskGui.
#		Override the required methods:
#			*update_gui(params: Dictionary)
#			@params the parameters that are generated in get_update_gui_dict()
#		
#			* When the user has changed their input data, call 
#			send_input_to_backend(_new_input_data: Dictionary)
#			it handles the networking stuff, and calls the
#			_handle_input_from_gui(_new_input_data: Dictionary) method,
#			that you overwrote in your child of BaseMaintenanceTask
#	
#	4. in the UIManager, edit the ui_list dictionary to add this new scene as a
#		value to it. The key you used should be supplied to the maintenance task
#		instance you created in step 2; under frontendMenuName  
#			
#------------------------------

# the name of the gui that should represent this task to the user
# as defined in UIManager.menus
export var frontendMenuName: String

var frontend

# peers that have opened a gui on their end
var peers = Array()

func register_gui(gui) -> bool:
	# only assign a gui if we don't already have a gui
	if frontend == null:
		frontend = gui
		# tell the server we have opened a gui
		rpc_id(1, "_register_peer", Network.get_my_id())
			
	# if the gui was previously assigned, the below expression will be false
	return frontend == gui

func unregister_gui(gui):
	if frontend == gui:
		frontend = null
		# tell the server we have closed a gui
		rpc_id(1, "_unregister_peer", Network.get_my_id())

master func _register_peer(caller_id: int):
	var peer_id = get_tree().get_rpc_sender_id()
	if caller_id != peer_id:
		return
	
	if peers.has(peer_id):
		# only one peer is allowed
		return 
		
	peers.append(peer_id)
	$Timer.set_has_peers(true)
	$Timer.start()
		
master func _unregister_peer(caller_id: int):
	var peer_id = get_tree().get_rpc_sender_id()
	if caller_id != peer_id:
		return
	
	peers.erase(peer_id)
	if peers.empty():
		# no peers left, no need to waste processing power and network bandwidth
		$Timer.set_has_peers(false)
	


var last_timer_fire: float
func _ready():
	set_network_master(1)
	# Make sure that the ui menu name exists
	# Did you assign it in the editor?
	assert(UIManager.is_ui_name_valid(self.frontendMenuName))
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
	UIManager.open_ui(self.frontendMenuName, {"linkedNode": self})
	
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
	
func get_update_gui_dict() -> Dictionary:
	# Never can be called on base class
	# Did you forget to assign the specific maintenance task(child of this node)
	# script to the maintenance task scene instance?
	assert(false)
	return {}
	
func _handle_input_from_gui(_new_input_data: Dictionary):
	# Never can be called on base class
	# Did you forget to assign the script to the maintenance task scene instance?
	assert(false)
	pass
	
