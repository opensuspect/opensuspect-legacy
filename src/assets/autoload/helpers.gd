extends Node

func pick_random(array: Array):
	randomize()
	var random_index : int = 0
	if len(array) > 0:
		random_index = randi() % len(array)
	return array[random_index]

func string_join(string_array: Array, separator: String) -> String:
	var combined_string: String = ""
	for index in range(len(string_array) - 1):
		combined_string += string_array[index] + separator
	combined_string += string_array[-1]
	return combined_string

func list_directory(path: String, recursive: bool = false) -> Array:
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

func map(in_value: float, in_value_min: float, in_value_max: float, out_value_min: float, out_value_max: float) -> float:
	return (in_value - in_value_min) * (out_value_max - out_value_min) / (in_value_max - in_value_min) + out_value_min

func filename_to_label(filename: String) -> String:
	return filename.replace("_", " ").replace("-", " and ")

func get_absolute_path_to(node: Node, subname: String = ""):
	var path: String = get_tree().get_root().get_path_to(node)
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
