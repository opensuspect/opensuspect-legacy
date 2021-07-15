extends Node

func pick_random(array: Array):
	randomize()
	var random_index : int = 0
	if len(array) > 0:
		random_index = randi() % len(array)
	return array[random_index]

func string_join(string_array: Array, separator: String) -> String:
	# Join an array of strings together, separated by 'separator'
	var combined_string: String = ""
	for index in range(len(string_array) - 1):
		combined_string += string_array[index] + separator
	combined_string += string_array[-1]
	return combined_string

# merge two dicts together, second dict will overwrite the first if they share a key
func merge_dicts(dict_a: Dictionary, dict_b: Dictionary) -> Dictionary:
	var dict: Dictionary = dict_a.duplicate(true)
	for key in dict_b:
		dict[key] = dict_b[key]
	return dict

func find_file(file_name: String, start_path: String = "res://", recursive: bool = true) -> String:
	# Find file 'file_name' starting at directory 'start_path' recursively.
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
	# Return an Array of all the files in directory 'path' recursively.
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
	files.sort()
	return files

func load_files_in_dir_with_exts(directory: String, exts: PoolStringArray) -> Array:
	var paths: Array = get_file_paths_in_dir_with_exts(directory, exts)
	var resources: Array = []
	for path in paths:
		var res: Resource = load(path)
		resources.append(res)
	return resources

func get_file_paths_in_dir_with_exts(directory: String, exts: PoolStringArray) -> Array:
	var paths: Array = []
	for ext in exts:
		paths += get_file_paths_in_dir(directory, ext)
	return paths

func get_file_paths_in_dir(directory: String, ext: String = "") -> Array:
	var paths: Array = []
	var dir = Directory.new()
	dir.open(directory)
	dir.list_dir_begin()
	while true:
		var file = dir.get_next()
		if file == "":
			# completely break out of the loop
			break
		# if file path doesn't have the right extension
		if not is_valid_file_name(file, ext):
			# skip to the next iteration of the loop
			continue
		var path: String = directory
		if not path.ends_with("/"):
			path += "/"
		path += file
		paths.append(path)
	dir.list_dir_end()
	return paths

func is_valid_file_name(file_name: String, ext: String = "") -> bool:
	if file_name == "":
		return false
	# if file path doesn't have the right extension
	if ext != "" and not file_name.ends_with(ext):
		return false
		# don't include non-files
	if file_name == "." or file_name == "..":
		return false
	# if file is actually a folder
	if file_name.split(".").size() < 2:
		return false
	return true

func map(in_value: float, in_value_min: float, in_value_max: float, out_value_min: float, out_value_max: float) -> float:
	# Map a value from an input range to an output range.
	return (in_value - in_value_min) * (out_value_max - out_value_min) / (in_value_max - in_value_min) + out_value_min

func filename_to_label(filename: String) -> String:
	return filename.replace("_", " ").replace("-", " and ")

func get_absolute_path_to(node: Node, subname: String = ""):
	var path: String = get_tree().get_root().get_path_to(node)
	path = "/root/" + path
	if subname != "":
		path = path + ":" + subname
	return NodePath(path)

func get_node_from_root(path: NodePath):
	return get_tree().get_root().get_node(path)

func get_node_or_null_from_root(path: NodePath):
	if not get_node_from_root(path):
		return null
	return get_node_from_root(path)

# get property from NodePath, for ex. get_node_property_from_root("UIManager:current_ui") will return the value of current_ui
# input path to node from root
func get_node_property_from_root(path: NodePath):
	var node = get_node_from_root(path)
	var subnames = path.get_concatenated_subnames()
	return node.get_indexed(subnames)

func object_has_method_with_args(object: Object, method: String, args: Array) -> bool:
	var method_args: Array = get_object_method_arg_names(object, method)
	for arg in args:
		if not method_args.has(arg):
			return false
	return true

func object_has_method_with_arg(object: Object, method: String, arg: String) -> bool:
	var method_args: Array = get_object_method_arg_names(object, method)
	var arg_names
	return method_args.has(arg)

func get_object_method_arg_amount(object: Object, method: String) -> int:
	return get_object_method_args(object, method).size()

func get_object_method_arg_names(object: Object, method: String) -> Array:
	var method_args: Array = get_object_method_args(object, method)
	var arg_names: Array = []
	for arg in method_args:
		arg_names.append(arg["name"])
	print(arg_names)
	return arg_names

func get_object_method_args(object: Object, method: String) -> Array:
	var object_methods: Array = object.get_method_list()
	for method_data in object_methods:
		if method_data["name"] != method:
			continue
		print(method_data)
		print(method_data["args"])
		return method_data["args"]
	return []
