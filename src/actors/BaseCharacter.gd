class_name BaseCharacter
extends BaseActor


var flip: bool = false

onready var sprite = get_node_or_null("Sprite")


func update_flip() -> void:
	var dir = vel.normalized()
	flip = flip if abs(dir.x) <= 0.5 else dir.x < 0
	sprite.flip_h = flip
