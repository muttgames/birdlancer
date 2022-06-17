class_name BaseCharacter
extends BaseActor


var flip: bool = false
var base_character_sprite_or_animated_sprite: Node2D = null


func update_flip() -> void:
	var dir = vel.normalized()
	flip = flip if abs(dir.x) <= 0.5 else dir.x < 0
	base_character_sprite_or_animated_sprite.flip_h = flip
