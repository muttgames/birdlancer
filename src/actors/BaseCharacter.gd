extends BaseActor

class_name BaseCharacter

onready var sprite = get_node_or_null("Sprite")
var flip = false

func update_flip():
	var dir = vel.normalized()
	flip = flip if abs(dir.x) <= 0.5 else dir.x < 0
	sprite.flip_h = flip
