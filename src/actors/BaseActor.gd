class_name BaseActor
extends CharacterBody2D


@export var friction: float = 100
@export var angular_fric: float = 0.01
@export var max_turn_speed: float = 100.0
@export var max_h_speed: float = 500.0
@export var max_jump_speed: float = 500.0
@export var max_fall_speed: float = 500.0
@export var mass: float = 1.0
@export var gravity: float = 300.0

var vel: Vector2 = Vector2.ZERO
var h_speed: float = 0.0
var v_speed: float = 0.0

var _angular_accel: float = 0.0
var _angular_vel: float = 0.0
var _prev_vel: Vector2 = vel
var _accel: Vector2 = Vector2.ZERO
var _speed: float = 0.0
var _impulses: Vector2 = Vector2()
var _angular_impulses: float = 0.0
var _prev_speed: float = 0.0
var _prev_accel: Vector2 = Vector2.ZERO


func apply_forces(delta: float, apply_friction:bool = true, up: Vector2 = Vector2.UP, _infinite_inertia: bool = true) -> void:
	#var fraction = Engine.get_physics_interpolation_fraction()
	_prev_vel = vel
	#print(just_jumped)
	apply_force(Vector2(0, gravity))
	
	if apply_friction:
		if abs(vel.x) < friction * delta:
			vel.x = 0
		else:
			_accel.x += friction * -(vel.normalized().x)
		if abs(vel.y) < friction * delta:
			vel.y = 0
		else:
			_accel.y += friction * -(vel.normalized().y)
		
	_prev_speed = _speed
	_angular_vel += _angular_impulses
	vel += _impulses
	vel += _accel * delta
	
	vel.x = clamp(vel.x, -max_h_speed, max_h_speed)
	vel.y = clamp(vel.y, -max_jump_speed, max_fall_speed)
	#global_position = LevelManager.clamp_to_bounds(global_position)
	self.velocity = vel
	self.up_direction = up
	self.max_slides = 4
	self.floor_max_angle = 0.785398
	# vel = move_and_slide(vel, up, false, 4, 0.785398, infinite_inertia)
	move_and_slide()
	vel = self.velocity

	_speed = vel.length()
	h_speed = abs(vel.x)
	v_speed = abs(vel.y)

	_prev_accel = _accel
	_accel = Vector2(0, 0)
	_impulses = Vector2(0, 0)
	_angular_impulses = 0
	_turn(delta)
	rotate(_angular_vel * delta)


func push(node: BaseActor) -> void:
	node.apply_force(node.global_position - global_position * node.accel_speed)


func move_directly(v: Vector2) -> void:
	self.motion_velocity = v
	var _res = move_and_slide()
	_speed = vel.length()


func rotate_directly(r, delta) -> void:
	rotation += r * delta


func apply_force(f: Vector2) -> void:
	_accel += f / mass


func apply_impulse(f: Vector2) -> void:
	_impulses += f / mass

	
func apply_impulse_angular(f: float) -> void:
	_angular_impulses += f / mass


func apply_force_angular(f: float) -> void:
	_angular_accel += f / mass


func accel_towards(global_character_position: Vector2, accel_speed: float) -> void:
	apply_force((global_character_position - self.global_position).normalized() * accel_speed)


func _turn(delta: float) -> void:
	_angular_vel += _angular_accel
	_angular_vel = clamp(_angular_vel, -max_turn_speed, max_turn_speed)
	_angular_vel *= pow(angular_fric, delta)
	_angular_accel = 0
