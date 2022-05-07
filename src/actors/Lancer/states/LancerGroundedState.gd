extends StateInterface


@export var min_speed: float
@export var max_speed: float
@export var min_anim_speed = 0.5
@export var max_anim_speed = 0.75


func enter() -> void:
	pass


func update(delta: float) -> Variant:
	host.update_flip()
	host.apply_forces(delta)
	var speed = host.h_speed / host.max_h_speed
	if speed > max_speed:
		return next_state
	if speed < min_speed and !host.moving:
		return prev_state
	if !host.is_on_floor():
		return "Jump"
	host.base_character_sprite_or_animated_sprite.speed_scale = Utils.map(speed, min_speed, max_speed, min_anim_speed, max_anim_speed)
	return null

func exit() -> void:
	host.base_character_sprite_or_animated_sprite.speed_scale = 1.0


func move(movement: Vector2) -> void:
	host.apply_force(movement * host.grounded_accel_speed)


func jump() -> void:
	queue_state_change("Jump")
	host.apply_impulse(Vector2(0, -host.jump_speed))
