extends Control

onready var current_part_label: Label = $CurrentPartLabel
onready var part_label: Label = $PartLabel

signal part_changed(new_part, part_name)

var parts: Dictionary = {}
var part_name = ""
var part_display_text = ""
var current_part_index: int

func _ready():
	part_label.text = part_display_text

func set_part_name(new_part_name: String, new_part_display_text: String):
	part_display_text = new_part_display_text
	part_name = new_part_name

func set_current_part(sprite_name: String) -> void:
	if not parts.has(sprite_name):
		current_part_index = 0
		var selected = parts.keys()[current_part_index]
		current_part_label.text = parts[selected]
		emit_signal("part_changed", selected, part_name)
	else:
		current_part_label.text = parts[sprite_name]
		current_part_index = parts.keys().find(sprite_name)
	# emit_signal("part_changed", parts[current_part_index], part_label.text)

func _on_LeftButton_pressed() -> void:
	current_part_index = (current_part_index - 1) % len(parts)
	var selected = parts.keys()[current_part_index]
	current_part_label.text = parts[selected]
	emit_signal("part_changed", selected, part_name)

func _on_RightButton_pressed() -> void:
	current_part_index = (current_part_index + 1) % len(parts)
	var selected = parts.keys()[current_part_index]
	current_part_label.text = parts[selected]
	emit_signal("part_changed", selected, part_name)
