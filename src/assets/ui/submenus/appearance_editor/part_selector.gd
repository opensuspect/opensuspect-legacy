extends Control

onready var current_part_label: Label = $CurrentPartLabel
onready var part_label: Label = $PartLabel

signal part_changed(new_part, part_name)

var parts: Array = []
var part_index: int

func _on_LeftButton_pressed() -> void:
	part_index = (part_index - 1) % len(parts)
	current_part_label.text = parts[part_index]
	emit_signal("part_changed", parts[part_index], part_label.text)

func _on_RightButton_pressed() -> void:
	part_index = (part_index + 1) % len(parts)
	current_part_label.text = parts[part_index]
	emit_signal("part_changed", parts[part_index], part_label.text)
