extends Node

func pick_random(array: Array):
	randomize()
	var random_index : int = 0
	if len(array) > 0:
		random_index = randi() % len(array)
	return array[random_index]

func string_join(string_array: Array, separator: String) -> String:
	"""Join an array of strings together, separated by 'separator'"""
	var combined_string: String = ""
	for index in range(len(string_array) - 1):
		combined_string += string_array[index] + separator
	combined_string += string_array[-1]
	return combined_string

func find_file(file_name: String, start_path: String = "res://", recursive: bool = true) -> String:
	"""Find file 'file_name' starting at directory 'start_path' recursively."""
	var directory := Directory.new()
	assert(directory.open(start_path) == OK)
	directory.list_dir_begin(true)
	var file: String = directory.get_next()
	while file != "":
		if file == file_name:
			return start_path + ("" if start_path.ends_with("/") else "/") + file
		if directory.current_is_dir() and recursive:
			var recursive_file: String = find_file(file_name, start_path + ("" if start_path.ends_with("/") else "/") + file, recursive)
			if recursive_file != "":
				return recursive_file
		file = directory.get_next()
	return ""

func list_directory(path: String, recursive: bool = false) -> Array:
	"""Return an Array of all the files in directory 'path' recursively."""
	var directory := Directory.new()
	assert(directory.open(path) == OK)
	var files: Array = []
	directory.list_dir_begin(true)
	var file_name: String = directory.get_next()
	while file_name != "":
		if directory.current_is_dir() and recursive:
			list_directory(file_name, recursive)
		else:
			files.append(file_name)
		file_name = directory.get_next()
	return files

func map(in_value: float, in_value_min: float, in_value_max: float, out_value_min: float, out_value_max: float) -> float:
	"""Map a value from an input range to an output range."""
	return (in_value - in_value_min) * (out_value_max - out_value_min) / (in_value_max - in_value_min) + out_value_min
