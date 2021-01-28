extends Node

func save_data(path: String, data: Dictionary) -> void:
	var save_data := File.new()
	if save_data.open(path, File.WRITE) == OK:
		save_data.store_line(to_json(data))
	save_data.close()

func load_data(path: String) -> Dictionary:
	var data: Dictionary = {}
	var load_data := File.new()
	if load_data.open(path, File.READ) == OK:
		var content: String = load_data.get_as_text()
		data = parse_json(content)
	load_data.close()
	return data
