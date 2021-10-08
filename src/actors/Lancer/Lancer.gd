extends BaseCharacter

class_name Lancer

export var flap_speed = 100.0
export var jump_speed = 200.0
export var aerial_accel_speed = 50.0
export var grounded_accel_speed = 300.0

onready var state_machine = $StateMachine
onready var spear = $Spear
onready var spear_position = $Spear.position
onready var collision_box = $CollisionShape2D
onready var collision_box_position = $CollisionShape2D.position
onready var bounce_timer = $BounceTimer
onready var camera = get_node_or_null("Camera2D")
onready var camera_target = $CameraTarget
onready var tween = $Tween

# is the user inputting movement
var moving = false

# have we bounced off something
var bouncing = false

func _ready() -> void:
	state_machine.init()

func _physics_process(delta):
	camera.position = lerp(camera.position, camera_target.position, 1 - pow(0.1, delta))
	state_machine.update(delta)
	Debug.dbg("lancer velocity", vel)
	Debug.dbg("lancer state", state_machine.state.name)
	moving = false

func update_flip():
	if bouncing:
		return
	.update_flip()
	update()
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

func _on_Spear_body_entered(body):
	bounce()
	pass # Replace with function body.
