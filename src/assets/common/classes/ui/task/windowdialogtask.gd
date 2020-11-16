extends WindowDialogBase

class_name WindowDialogTask

#called by ui system
func base_open():
	#call base_open() in parent class
	.base_open()

#called by self or ui system
func base_close():
	#call base_close() in parent class
	.base_close()
