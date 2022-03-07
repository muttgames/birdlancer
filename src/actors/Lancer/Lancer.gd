class_name Lancer
extends BaseCharacter


@export var flap_speed: float = 100.0
@export var jump_speed: float = 200.0
@export var aerial_accel_speed: float = 50.0
@export var grounded_accel_speed: float = 300.0

var moving: bool = false  # is the user inputting movement
var bouncing: bool = false  # have we bounced off something

@onready var player_controller: Node = $PlayerController
@onready var state_machine: Node = $StateMachine
@onready var spear: Area2D = $Spear
@onready var spear_position: Vector2 = $Spear.position
@onready var collision_box: CollisionShape2D = $CollisionShape2D
@onready var collision_box_position: Vector2 = $CollisionShape2D.position
@onready var bounce_timer: Timer = $BounceTimer
@onready var camera = get_node_or_null("Camera2D")
@onready var camera_target: Position2D = $CameraTarget


func _ready() -> void:
	# warning-ignore-all:return_value_discarded
	spear.connect("body_entered", _on_Spear_body_entered)
	player_controller.connect("requested_move", _on_PlayerController_requested_move)
	player_controller.connect("requested_jump", _on_PlayerController_requested_jump)

	base_character_sprite_or_animated_sprite = $Sprite

	state_machine.init()


func _physics_process(delta: float) -> void:
	camera.position.lerp(camera_target.position, 1 - pow(0.1, delta))
	state_machine.update(delta)
	Debug.dbg("lancer velocity", vel)
	Debug.dbg("lancer state", state_machine.state.name)
	moving = false


func update_flip():
	if bouncing:
		return
	super.update_flip() # use the super keyword to call a function defined in the superclass instead of the overridden version
	super.update()
	spear.position.x = -spear_position.x if flip else spear_position.x
	collision_box.position.x = -collision_box_position.x if flip else collision_box_position.x


func bounce():
	vel.x = -vel.x/2
	bouncing = true
	bounce_timer.start()
	await Signal(bounce_timer.timeout)
	bouncing = false


func _on_PlayerController_requested_jump():
	state_machine.try("jump")


func _on_PlayerController_requested_move(movement):
	if !bouncing:
		if movement.x != 0:
			camera_target.position.x = abs(camera_target.position.x) * movement.x
		state_machine.try("move", [movement])
		moving = true


func _on_Spear_body_entered(_body: Object) -> void:
	bounce()
