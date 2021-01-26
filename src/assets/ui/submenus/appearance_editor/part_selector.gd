extends Control

onready var current_part_label: Label = $CurrentPartLabel
onready var part_label: Label = $PartLabel

signal part_changed(new_part, part_name)

var parts: Array = []
var current_part_index: int

func set_current_part(part_name: String) -> void:
	if not parts.has(part_name):
		return
	current_part_label.text = Helpers.filename_to_label(part_name)
	current_part_index = parts.find(part_name)
	# emit_signal("part_changed", parts[current_part_index], part_label.text)

func _on_LeftButton_pressed() -> void:
	current_part_index = (current_part_index - 1) % len(parts)
	current_part_label.text = Helpers.filename_to_label(parts[current_part_index])
	emit_signal("part_changed", parts[current_part_index], part_label.text)

func _on_RightButton_pressed() -> void:
	current_part_index = (current_part_index + 1) % len(parts)
	current_part_label.text = Helpers.filename_to_label(parts[current_part_index])
	emit_signal("part_changed", parts[current_part_index], part_label.text)
