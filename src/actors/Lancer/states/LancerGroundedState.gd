extends StateInterface

export(String) var next_state
export(String) var prev_state
export(float) var min_speed
export(float) var max_speed
export(float) var min_anim_speed = 0.5
export(float) var max_anim_speed = 0.75

func enter():
	pass

func update(delta):
	host.apply_forces(delta)
	var speed = host.h_speed / host.max_h_speed
	
	if speed > max_speed:
		return next_state
	if speed < min_speed and !host.moving:
		return prev_state
	if !host.is_on_floor():
		return "Jumping"
	host.sprite.speed_scale = Utils.map(speed, min_speed, max_speed, min_anim_speed, max_anim_speed)

func exit():
	host.sprite.speed_scale = 1.0
	pass

func move(movement):
	host.apply_force(movement * host.grounded_accel_speed)

func jump():
	queue_state_change("Jumping")
	host.apply_impulse(Vector2(0, -host.jump_speed))
	pass
