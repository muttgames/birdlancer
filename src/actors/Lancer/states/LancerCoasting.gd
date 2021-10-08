extends StateInterface

onready var flap_timer = $FlapTimer
var buffered_flap = false
export var flap_buffer_time = 0.2

func enter():
	buffered_flap = false
	pass

func update(delta):
	host.update_flip()
	host.apply_forces(delta, false)
	if host.is_on_floor():
		return "Idle"

func exit():
	pass

func flap():
	if flap_timer.is_stopped():
		# stop the user from infinitely gaining height on the jump's ascent
		if host.vel.y < 0:
			host.vel.y = 0
		host.apply_impulse(Vector2(0, -host.flap_speed))
		flap_timer.start()
		queue_state_change("Jump")
	elif flap_timer.time_left <= flap_buffer_time:
		buffered_flap = true

func move(movement: Vector2):
	host.apply_force(movement * host.aerial_accel_speed)
	
func jump():
	flap()
	pass

func _on_FlapTimer_timeout():
	if buffered_flap:
		flap()
		buffered_flap = false
	pass
