tool
extends Node2D


enum POSITION_ENUM {NORTH, EAST, SOUTH, WEST}

export(POSITION_ENUM) var joint_position: int = 0  # North
export(bool) var is_jointed: bool = false


func _ready() -> void:
	$"Area2D/CollisionShape2D".shape.extents = Globals.JOINT_SIZE/2
	$Sprite.scale = Globals.JOINT_SIZE
	if joint_position in [1, 3]:  # West or East
		self.rotation_degrees = 90.0
	$Sprite.visible = false


func _process(_delta: float) -> void:
	if OS.has_feature("editor"):
		# https://godotengine.org/qa/97382/know-whether-the-node-is-running-in-the-editor-or-in-game
		$Sprite.visible = true
		var color: Color = Color.black
		match joint_position:
			0: # north
				color = Color.blue
			1: # east
				color = Color.yellow
			2: # south
				color = Color.red
			3: # west
				color = Color.green
		$Sprite.texture.gradient.colors[0] = color
