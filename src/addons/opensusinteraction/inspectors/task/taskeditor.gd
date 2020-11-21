extends EditorProperty

class_name TaskEditor

var updating = false
var spin = EditorSpinSlider.new()


func _init():
	#set_bottom_editor(spin) to create below property name
	add_child(spin)
	add_focusable(spin)
	spin.set_min(0)
	spin.set_max(1000)
	spin.connect("value_changed", self, "_spin_changed")


func _spin_changed(value):
	if (updating):
		return
	emit_changed(get_edited_property(), value)


func update_property():
	var new_value = get_edited_object()[get_edited_property()]
	updating = true
	spin.set_value(new_value)
	updating = false
