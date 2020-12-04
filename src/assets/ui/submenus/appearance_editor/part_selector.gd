extends Control

onready var current_part_label: Label = $CurrentPartLabel

var parts: Array = []
var part_index: int

func _on_LeftButton_pressed() -> void:
	part_index = (part_index - 1) % len(parts)
	current_part_label.text = parts[part_index]

func _on_RightButton_pressed() -> void:
	part_index = (part_index + 1) % len(parts)
	current_part_label.text = parts[part_index]
