extends Node2D

const PositionSignal: PackedScene = preload("res://src/levels/ProcGenCloseJointsTest/PositionSignal.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	var unused_joints_coordinates_array: Array = $RoomTest.close_unused_joints()

	for joint_coordinates in unused_joints_coordinates_array:
		var position_signal = PositionSignal.instantiate()
		self.add_child(position_signal)
		position_signal.position = joint_coordinates
