extends Area2D

export(Resource) var interact_resource
export(bool) var only_main_player = false
export(int, 1, 10000) var players_to_activate = 1
export(bool) var interact_on_exit = false
var overlappingBodies: Array = []
var pressed: bool = false

func _ready():
	interact_resource.init_resource(self)
#	print(interact.get_interact_data())

func interact():
	interact_resource.interact(self)

func update():
	if overlappingBodies.size() < players_to_activate:
		if not pressed:
			return
		pressed = false
		if interact_on_exit:
			interact()
	else:
		if pressed:
			return
		pressed = true
		interact()

func get_state() -> bool:
	return pressed

func _on_standbutton_body_entered(body):
	if overlappingBodies.has(body):
		return
	if not body.is_in_group("players"):
		return
	if only_main_player:
		if int(body.id) != Network.get_my_id():
			return
	overlappingBodies.append(body)
	update()

func _on_standbutton_body_exited(body):
	overlappingBodies.erase(body)
	update()
