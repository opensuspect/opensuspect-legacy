extends Sprite

func _ready() -> void:
	# Duplicate the ShaderMaterial so that changes to shader parameters in one player material don't affect all players
	set_material(material.duplicate())
