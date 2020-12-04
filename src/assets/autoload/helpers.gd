extends Node

func string_join(string_array: Array, separator: String) -> String:
	var combined_string: String = ""
	for index in range(len(string_array) - 1):
		combined_string += string_array[index] + separator
	combined_string += string_array[-1]
	return combined_string

func map(in_value: float, in_value_min: float, in_value_max: float, out_value_min: float, out_value_max: float) -> float:
	return (in_value - in_value_min) * (out_value_max - out_value_min) / (in_value_max - in_value_min) + out_value_min
