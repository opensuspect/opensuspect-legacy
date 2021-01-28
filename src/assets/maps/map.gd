extends Node2D

onready var spawnpoints: Node2D = $SpawnPoints
onready var props: Node2D = $Props
onready var corpses: Node2D = props.get_node("Corpses")
onready var interactive: Node2D = $Interactive
onready var items: Node2D = interactive.get_node("Items")
