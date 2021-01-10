extends Resource

class_name MapInfo

export(String) var name setget ,get_name
export(String, MULTILINE) var desc setget ,get_desc
export(Texture) var thumbnail setget ,get_thumbnail
export(String, FILE, "*.tscn") var scene_path setget ,get_scene_path

func get_name() -> String:
	return name

func get_desc() -> String:
	return desc

func get_thumbnail() -> Texture:
	return thumbnail

func get_scene_path() -> String:
	return scene_path
