extends BaseActor

class_name BaseCharacter

onready var sprite = get_node_or_null("Sprite")
var flip = false

func update_flip():
	flip = flip if accel.x == 0 else accel.x < 0
	sprite.flip_h = flip
