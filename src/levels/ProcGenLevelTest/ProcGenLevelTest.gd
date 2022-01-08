extends Node2D


export(String) var rooms_folder_path: String = "res://src/levels/ProcGenLevelTest/Rooms/"
export(PackedScene) var player_model: PackedScene
export(PackedScene) var specify_initial_room: PackedScene = null
export(PackedScene) var specify_final_room: PackedScene = null
export(int) var number_of_rooms: int = 20


var _rooms_list: Array = []
var _rooms_folder: Directory
var _initial_room: Node2D
var _final_room: Node2D
var _rooms_in_tree: Array = []


func _ready() -> void:
	_load_rooms()
	_set_initial_room()
	yield(_build_room_tree(), "completed")
	yield(_set_final_room(), "completed")
	_deactivate_all_areas()
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

	yield(get_tree(), "physics_frame")  # this is here to avoid "First argument of yield() not of type object."
	while index <= number_of_rooms:

		# Select a random room in the room tree.
		var selected_room = _rooms_in_tree[randi() % _rooms_in_tree.size()]

		# If the source room is blacklisted, continue.
		if selected_room in blacklisted_source_rooms:
			continue

		var inner_success = false
		var inner_index = 0
		var inner_limit = 5
		var appending_error = 3
		var blacklisted_inner_rooms: Array = []

		# Keep trying to fit a new room around the current non-blacklisted room
		# Until we succeed or run out of attempts.
		while not(inner_success) and inner_index < inner_limit:

			# Select a random room from the room list.
			var appending_room = _rooms_list[randi() % _rooms_list.size()].instance()

			# If appending room has been previously blacklisted, continue.
			if appending_room in blacklisted_inner_rooms:
				inner_index += 1
				continue
			
			# Try appending rooms.
			appending_error = yield(_append_rooms(selected_room, appending_room), "completed")
			if appending_error == 1:  # no available joints, blacklist the selected room!
				blacklisted_source_rooms.append(selected_room)
				break
			elif appending_error == 2:  # no available space, try again the inner cycle
				blacklisted_inner_rooms.append(appending_room)
				inner_index += 1
			elif appending_error == 0:  # success!
				_rooms_in_tree.append(appending_room)
				inner_success = true
				index += 1

		
func _append_rooms(source_room, target_room) -> int:
	yield(get_tree(), "physics_frame")  # this is here to avoid "First argument of yield() not of type object."

	# Returns
	var no_available_joints_error = 1
	var no_space_error = 2
	var success = 0

	# Check if source room has available joints.
	var available_joints: Array = []
	for joint in source_room.get_node("Joints").get_children():
		if joint is ProceduralJoint:
			if not(joint.is_jointed):
				available_joints.append(joint)

	# If there are no available joints, return no_available_joints_error.
	if len(available_joints) == 0:
		return no_available_joints_error

	# Select a random joint from the source room.
	var source_joint = available_joints[randi() % available_joints.size()]
	var source_direction = source_joint.joint_position

	# Select the target joint of the new room.
	var target_direction = (source_direction+2)%4
	var target_joint = null
	if is_instance_valid(target_room):	# (because of all the yields!)
		for joint in target_room.get_node("Joints").get_children():
			if joint.joint_position == target_direction:
				target_joint = joint
	else:
		return no_space_error
	
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

	# Check for collisions with all the rooms of the tree
	# TODO this should be changed, should check only "neighbours"... maybe it would be costly though
	yield(get_tree(), "physics_frame")
	var target_collider: ProceduralCollider = null
	if is_instance_valid(target_room):	# (because of all the yields!)
		target_collider	= target_room.get_node("ProceduralCollider")
	else:
		return no_space_error
	for room in _rooms_in_tree:
		var room_collider: ProceduralCollider = room.get_node("ProceduralCollider")
		if (target_collider in room_collider.get_overlapping_areas()) or (room_collider in target_collider.get_overlapping_areas()):
			target_room.queue_free()
			return no_space_error
	
	# Everything's good!
	source_joint.is_jointed = true
	target_joint.is_jointed = true
	return success  # success!


func _set_final_room() -> void:
	yield(get_tree(), "physics_frame")  # this is here to avoid "First argument of yield() not of type object."
	if specify_final_room:
		print("TODO")  # TODO
		_final_room = _rooms_list[randi() % _rooms_list.size()].instance()  # TODO
		var success = false
		while not(success):
			var selected_room = _rooms_in_tree[randi() % _rooms_in_tree.size()]
			var appending_error = yield(_append_rooms(selected_room, _final_room), "completed")
			success = (appending_error == 0)
	else:
		_final_room = _rooms_list[randi() % _rooms_list.size()].instance()
		var success = false
		while not(success):
			var selected_room = _rooms_in_tree[randi() % _rooms_in_tree.size()]
			var appending_error = yield(_append_rooms(selected_room, _final_room), "completed")
			success = (appending_error == 0)
	_rooms_in_tree.append(_final_room)


func _deactivate_all_areas() -> void:
	yield(get_tree(), "physics_frame")  # wait a bit!
	for room in _rooms_in_tree:
		var room_collider: ProceduralCollider = room.get_node("ProceduralCollider")
		if room_collider is ProceduralCollider:
			room_collider.monitorable = false
			room_collider.monitoring = false
			for joint in room.get_node("Joints").get_children():
				if joint is ProceduralJoint:
					var area_2d: Area2D = joint.get_node("Area2D")
					area_2d.monitorable = false
					area_2d.monitoring = false


func _spawn_player() -> void:
	var player_instance: Node2D = player_model.instance()
	self.add_child(player_instance)
	player_instance.position = _initial_room.get_node("SpawnPosition").position
