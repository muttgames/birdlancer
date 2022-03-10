extends Node
# NOTICE: EDITOR MUST BE RESTARTED TO RESET THE "CACHE" OF THE CONSTANTS FOR
# "TOOL" NODES! (eg. for ProceduralJoints)

const JOINT_SIZE: Vector2 = Vector2(32, 16)  # horizontal: first value is the short side
const GRID_SIZE: Vector2 = Vector2(16, 16)

func _ready() -> void:
	# also check again that JOINT_SIZE is a multiple of GRID_SIZE
	# warning-ignore-all: assert_always_true
	assert(fmod(Globals.JOINT_SIZE.x, Globals.GRID_SIZE.x) == 0, "JOINT_SIZE.x is not a multiple of GRID_SIZE.x!") 
	assert(fmod(Globals.JOINT_SIZE.y, Globals.GRID_SIZE.y) == 0, "JOINT_SIZE.y is not a multiple of GRID_SIZE.y!") 
