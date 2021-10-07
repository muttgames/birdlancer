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

var moving = false

func _ready() -> void:
	state_machine.init()

func _physics_process(delta):
	update_flip()
	state_machine.update(delta)
	Debug.dbg("lancer state", state_machine.state.name)
	moving = false

func update_flip():
	.update_flip()
	spear.position.x = -spear_position.x if flip else spear_position.x
	collision_box.position.x = -collision_box_position.x if flip else collision_box_position.x

func _on_PlayerController_jump():
	state_machine.try("jump")

func _on_PlayerController_move(movement):
	state_machine.try("move", [movement])
	moving = true
