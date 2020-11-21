extends EditorInspectorPlugin


func can_handle(object):
	return object is Task


func parse_property(object, type, path, hint, hint_text, usage):
	if type == TYPE_INT:
		#add_custom_control(load("res://assets/ui/hud/defaulthud/defaulthud.tscn").instance())
		add_property_editor(path, TaskEditor.new())
		return true
	else:
		return false
