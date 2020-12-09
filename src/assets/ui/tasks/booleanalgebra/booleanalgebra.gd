extends BaseMaintenanceTaskGui

var byte0_children
var byte1_children
var answer_children

func _ready():
	byte0_children = get_node(NodePath("Byte0")).get_children()
	byte1_children = get_node(NodePath("Byte1")).get_children()
	answer_children = get_node(NodePath("Answer")).get_children()

	
func _color_bytes(byte: Array, rects: Array):
	for i in range(byte.size()):
		var color = Color(byte[i], 1, 1)
		rects[i].color = color

func update_backend(index: int):
	if backend != null:
		backend.input_from_gui({"index_to_flip": index})

func update_gui(params: Dictionary):
	assert(params.has_all(["byte0", "byte1", "answer"]))
	_color_bytes(params["byte0"], byte0_children)
	_color_bytes(params["byte1"], byte1_children)
	_color_bytes(params["answer"], answer_children)

func getGuiName() -> String:
	return "booleanalgebra"

func _on_answer_0_pressed():
	update_backend(0)


func _on_answer_1_pressed():
	update_backend(1)


func _on_answer_2_pressed():
	update_backend(2)


func _on_answer_3_pressed():
	update_backend(3)


func _on_answer_4_pressed():
	update_backend(4)


func _on_answer_5_pressed():
	update_backend(5)


func _on_answer_06pressed():
	update_backend(6)


func _on_answer_7_pressed():
	update_backend(7)
