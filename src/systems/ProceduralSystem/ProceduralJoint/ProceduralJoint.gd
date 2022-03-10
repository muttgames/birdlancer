@tool
extends Node2D
class_name ProceduralJoint


enum POSITION_ENUM {NORTH, EAST, SOUTH, WEST}

@export var joint_position: int = 0  # North
@export var is_jointed: bool = false


func _ready() -> void:
	_update_shape()


func _process(_delta: float) -> void:
	_update_shape()
	

func _update_shape() -> void:
	$"Area2D/CollisionShape2D".shape.extents = Globals.JOINT_SIZE/2
	$Sprite.scale = Globals.JOINT_SIZE
	if joint_position in [1, 3]:  # West or East
		rotation = deg2rad(90.0)

	if Engine.is_editor_hint():
		# https://docs.godotengine.org/it/stable/classes/class_engine.html
		$Sprite.visible = true
		var color: Color = Color.BLACK
		match joint_position:
			0: # north
				color = Color.BLUE
				rotation = deg2rad(0.0)
			1: # east
				color = Color.YELLOW
				rotation = deg2rad(90.0)
			2: # south
				color = Color.RED
				rotation = deg2rad(0.0)
			3: # west
				color = Color.GREEN
				rotation = deg2rad(90.0)
		$Sprite.texture.gradient.colors[0] = color
	else:
		$Sprite.visible = false