extends Node2D


export(String) var rooms_folder_path: String = "res://src/levels/ProcGenLevelTest/Rooms/"
export(PackedScene) var player_model: PackedScene
export(PackedScene) var specify_initial_room: PackedScene = null
export(PackedScene) var specify_final_room: PackedScene = null
export(int) var number_of_rooms: int = 3


var _rooms_list: Array = []
var _rooms_folder: Directory
var _initial_room: Node2D
var _final_room: Node2D
var _rooms_in_tree: Array = []


func _ready() -> void:
	_load_rooms()
	_set_initial_room()
	_build_room_tree()
	_set_final_room()
	_spawn_player()
	
	
# ------------------------------------------------------------------------------


func _load_rooms() -> void:
	_rooms_folder = Directory.new()

	#warning-ignore:return_value_discarded
	_rooms_folder.open(rooms_folder_path)

	#warning-ignore:return_value_discarded
	_rooms_folder.list_dir_begin()

	var file_list: Array = []
	while true:
		var file = _rooms_folder.get_next()
		if file == "":
			break
		elif not file.begins_with("."):
			file_list.append(file)
	_rooms_folder.list_dir_end()

	for file in file_list:
		if 'tscn' in file:
			var loaded_room = load(rooms_folder_path +"/"+file)
			_rooms_list.append(loaded_room)


func _set_initial_room() -> void:
	if specify_initial_room:
		print("TODO")  # TODO
		_initial_room = _rooms_list[randi() % _rooms_list.size()].instance()  # TODO
	else:
		_initial_room = _rooms_list[randi() % _rooms_list.size()].instance()
	self.add_child(_initial_room)
	_rooms_in_tree.append(_initial_room)


func _build_room_tree() -> void:
	var index: int = 0+1+1  # initial room and final room must be counted!
	var blacklisted_source_rooms: Array = []

	while index < number_of_rooms:
		# Select a random room in the room tree.
		var selected_room = _rooms_in_tree[randi() % _rooms_in_tree.size()]

		# If the source room is blacklisted, continue.
		if selected_room in blacklisted_source_rooms:
			continue

		# Select a random room from the room list.
		var appending_room = _rooms_list[randi() % _rooms_list.size()].instance()
		
		# Append rooms.
		var success = _append_rooms(selected_room, appending_room)

		if not(success):
			blacklisted_source_rooms.append(selected_room)
			continue
		else:
			_rooms_in_tree.append(appending_room)
			index += 1

		
func _append_rooms(source_room, target_room) -> bool:

	# Check if source room has available joints.
	var available_joints: Array = []
	for joint in source_room.get_node("Joints").get_children():
		if not(joint.is_jointed):
			available_joints.append(joint)

	# If there are no available joints, return false.
	if len(available_joints) == 0:
		return false

	# Select a random joint from the source room.
	var source_joint = available_joints[randi() % available_joints.size()]
	var source_direction = source_joint.joint_position

	# Select the target joint of the new room.
	var target_direction = (source_direction+2)%4
	var target_joint = null
	for joint in target_room.get_node("Joints").get_children():
		if joint.joint_position == target_direction:
			target_joint = joint
	
	# Add new room and position it using the joint positions.
	var source_joint_global_position : Vector2 = source_joint.global_position
	var offset := Vector2.ZERO
	match source_joint.joint_position:
		0:  # North
			offset.y = - Globals.JOINT_SIZE.y
		1:  # East
			offset.x = Globals.JOINT_SIZE.y
		2:  # South
			offset.y = Globals.JOINT_SIZE.y
		3:   # West
			offset.x = - Globals.JOINT_SIZE.y
	self.add_child(target_room)
	var target_joint_global_position : Vector2 = target_joint.global_position
	target_room.global_position = source_joint_global_position - target_joint_global_position + offset
	source_joint.is_jointed = true
	target_joint.is_jointed = true

	return true  # success!


func _set_final_room() -> void:
	if specify_final_room:
		print("TODO")  # TODO
		_final_room = _rooms_list[randi() % _rooms_list.size()].instance()  # TODO
		var success = false
		while not(success):
			var selected_room = _rooms_in_tree[randi() % _rooms_in_tree.size()]
			success = _append_rooms(selected_room, _final_room)
	else:
		_final_room = _rooms_list[randi() % _rooms_list.size()].instance()
		var success = false
		while not(success):
			var selected_room = _rooms_in_tree[randi() % _rooms_in_tree.size()]
			success = _append_rooms(selected_room, _final_room)
	_rooms_in_tree.append(_final_room)


func _spawn_player() -> void:
	var player_instance: Node2D = player_model.instance()
	self.add_child(player_instance)
	player_instance.position = _initial_room.get_node("SpawnPosition").position
