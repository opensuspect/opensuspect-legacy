extends EditorInspectorPlugin

func can_handle(object):
	
	
	
	return true

func parse_property(object, type, path, hint, hint_text, usage):
	if type == TYPE_INT:
		#add_property_editor(path, MyIntEditor.new())
		
		#return true to notify inspector that this script is handling the property
		return true
	return false
