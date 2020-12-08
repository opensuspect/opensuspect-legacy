extends IPoolable
class_name BackgroundObject

onready var sprite: Sprite = $Sprite

# Array of textures to choose from and set the sprite to
export (Array, Texture) var textures

func _ready() -> void:
	$Sprite.texture = Helpers.pick_random(textures)
