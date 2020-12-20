extends Node2D

func _ready():
	pass

func applyCustomization(customizationData):
	"""
	Receives the customization data, and applies it to the current instance.
	"""
	
	if customizationData.empty():
		print("Empty customization data received")
		return

	var body: Polygon2D = self.get_node("Body")
	var left_leg: Polygon2D = self.get_node("LeftLeg")
	var left_arm: Polygon2D = self.get_node("LeftArm")
	var right_leg: Polygon2D = self.get_node("RightLeg")
	var right_arm: Polygon2D = self.get_node("RightArm")
	var spine: Bone2D = self.get_node("Skeleton/Spine")
	var clothes: Sprite = spine.get_node("Clothes")
	var pants: Sprite = spine.get_node("Pants")
	var facial_hair: Sprite = spine.get_node("FacialHair")
	var face_wear: Sprite = spine.get_node("FaceWear")
	var hat_hair: Sprite = spine.get_node("HatHair")
	var mouth: Sprite = spine.get_node("Mouth")

	var appearance: Dictionary = customizationData["Appearance"]
	self.material.set_shader_param("skin_color", Color(appearance["Skin Color"]))
	left_leg.texture = load(appearance["Clothes"]["left_leg"]["texture_path"])
	left_arm.texture = load(appearance["Clothes"]["left_arm"]["texture_path"])
	right_leg.texture = load(appearance["Clothes"]["right_leg"]["texture_path"])
	right_arm.texture = load(appearance["Clothes"]["right_arm"]["texture_path"])
	clothes.texture = load(appearance["Clothes"]["clothes"]["texture_path"])
	pants.texture = load(appearance["Clothes"]["pants"]["texture_path"])
	facial_hair.texture = load(appearance["Facial Hair"]["texture_path"])
	face_wear.texture = load(appearance["Face Wear"]["texture_path"])
	hat_hair.texture = load(appearance["Hat/Hair"]["texture_path"])
	mouth.texture = load(appearance["Mouth"]["texture_path"])
