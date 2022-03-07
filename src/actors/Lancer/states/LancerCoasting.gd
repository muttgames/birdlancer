extends StateInterface


@export var flap_buffer_time: float = 0.2

var _buffered_flap: bool = false

@onready var flap_timer: Timer = $FlapTimer


func _ready() -> void:
	# warning-ignore:return_value_discarded
	flap_timer.connect("timeout", _on_FlapTimer_timeout)


func enter() -> void:
	_buffered_flap = false


func update(delta: float):
	host.update_flip()
	host.apply_forces(delta, false)
	if host.is_on_floor():
		return "Idle"


func exit() -> void:
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
		_buffered_flap = true


func move(movement: Vector2) -> void:
	host.apply_force(movement * host.aerial_accel_speed)


func jump() -> void:
	flap()


func _on_FlapTimer_timeout() -> void:
	if _buffered_flap:
		flap()
		_buffered_flap = false
