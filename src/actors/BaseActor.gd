extends KinematicBody2D

class_name BaseActor

export(float) var friction = 100
export(float) var angular_fric = 0.01


var angular_accel = 0.0
var angular_vel = 0.0
var vel = Vector2(0, 0)
var prev_vel = vel
var accel = Vector2(0, 0)
var speed = 0.0
var impulses = Vector2()
var angular_impulses = 0.0
var prev_speed = 0.0
var prev_accel = Vector2()
var h_speed = 0.0
var v_speed = 0.0
export var max_turn_speed = 100.0
export var max_h_speed = 500.0
export var max_jump_speed = 500.0
export var max_fall_speed = 500.0
export var mass = 1.0
export var gravity = 300.0

func apply_forces(delta, apply_friction=true, up=Vector2.UP, infinite_inertia=true) -> void:
#	var fraction = Engine.get_physics_interpolation_fraction()
	prev_vel = vel
	#	print(just_jumped)
	apply_force(Vector2(0, gravity))
	
	if apply_friction:
		if abs(vel.x) < friction * delta:
			vel.x = 0
		else:
			accel.x += friction * -(vel.normalized().x)
		if abs(vel.y) < friction * delta:
			vel.y = 0
		else:
			accel.y += friction * -(vel.normalized().y)
		
	prev_speed = speed
	angular_vel += angular_impulses
	vel += impulses
	vel += accel * delta
	
	vel.x = clamp(vel.x, -max_h_speed, max_h_speed)
	vel.y = clamp(vel.y, -max_jump_speed, max_fall_speed)
#	global_position = LevelManager.clamp_to_bounds(global_position)
	vel = move_and_slide(vel, up, false, 4, 0.785398, infinite_inertia)
	speed = vel.length()
	h_speed = abs(vel.x)
	v_speed = abs(vel.y)

	prev_accel = accel
	accel = Vector2(0, 0)
	impulses = Vector2(0, 0)
	angular_impulses = 0
	_turn(delta)
	rotate(angular_vel * delta)

func push(node: BaseActor) -> void:
	node.apply_force(node.global_position - global_position * node.accel_speed)

func move_directly(v) -> void:
	move_and_slide(v)
	speed = vel.length()

func rotate_directly(r, delta) -> void:
	rotation += r * delta

func apply_force(f: Vector2) -> void:
	accel += f / mass

func apply_impulse(f: Vector2) -> void:
	impulses += f / mass
	
func apply_impulse_angular(f: float) -> void:
	angular_impulses += f / mass

func apply_force_angular(f: float) -> void:
	angular_accel += f / mass

func accel_towards(global_position: Vector2, accel_speed):
	apply_force((global_position - self.global_position).normalized() * accel_speed)

func _turn(delta: float) -> void:
	angular_vel += angular_accel
	angular_vel = clamp(angular_vel, -max_turn_speed, max_turn_speed)
	angular_vel *= pow(angular_fric, delta)
	angular_accel = 0
