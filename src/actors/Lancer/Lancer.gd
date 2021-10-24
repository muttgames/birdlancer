class_name Lancer
extends BaseCharacter


export var flap_speed: float = 100.0
export var jump_speed: float = 200.0
export var aerial_accel_speed: float = 50.0
export var grounded_accel_speed: float = 300.0

var moving: bool = false  # is the user inputting movement
var bouncing: bool = false  # have we bounced off something

onready var player_controller: Node = $PlayerController
onready var state_machine: Node = $StateMachine
onready var spear: Area2D = $Spear
onready var spear_position: Vector2 = $Spear.position
onready var collision_box: CollisionShape2D = $CollisionShape2D
onready var collision_box_position: Vector2 = $CollisionShape2D.position
onready var bounce_timer: Timer = $BounceTimer
onready var camera = get_node_or_null("Camera2D")
onready var camera_target: Position2D = $CameraTarget
onready var tween: Tween = $Tween


func _ready() -> void:
	# warning-ignore-all:return_value_discarded
	spear.connect("body_entered", self, "_on_Spear_body_entered")
	player_controller.connect("move", self, "_on_PlayerController_move")
	player_controller.connect("jump", self, "_on_PlayerController_jump")
	
	state_machine.init()


func _physics_process(delta: float) -> void:
	camera.position = lerp(camera.position, camera_target.position, 1 - pow(0.1, delta))
	state_machine.update(delta)
	Debug.dbg("lancer velocity", vel)
	Debug.dbg("lancer state", state_machine.state.name)
	moving = false


func update_flip():
	if bouncing:
		return
	.update_flip()  # the "dot" calls the equally named "update_flip" function of the base class BaseCharacter
	.update()  # same here, for the "update" function
	spear.position.x = -spear_position.x if flip else spear_position.x
	collision_box.position.x = -collision_box_position.x if flip else collision_box_position.x


func bounce():
	vel.x = -vel.x/2
	bouncing = true
	bounce_timer.start()
	yield(bounce_timer, "timeout")
	bouncing = false


func _on_PlayerController_jump():
	state_machine.try("jump")


func _on_PlayerController_move(movement):
	if !bouncing:
		if movement.x != 0:
			camera_target.position.x = abs(camera_target.position.x) * movement.x
		state_machine.try("move", [movement])
		moving = true


func _on_Spear_body_entered(_body: PhysicsBody2D) -> void:
	bounce()
