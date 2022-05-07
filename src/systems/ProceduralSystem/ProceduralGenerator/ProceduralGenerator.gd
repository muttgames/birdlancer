extends Node2D
class_name ProceduralGenerator


@export var rooms_folder_path: String = ""
@export var player_model: PackedScene = null
@export var specify_initial_room: PackedScene = null
@export var specify_final_room: PackedScene = null
@export var number_of_rooms: int = 30


var _rooms_list: Array = []
var _rooms_folder: Directory
var _initial_room: PackedScene
var _initial_room_instance: ProceduralRoomController
var _final_room: PackedScene
var _final_room_instance: ProceduralRoomController
var _rooms_in_tree: Array = []


func _ready() -> void:
	_load_rooms()
	_set_initial_room()
	await _build_room_tree()
	await _set_final_room()
	_close_all_unused_joints()
	_deactivate_all_areas()
	_spawn_player()
	
	
# ------------------------------------------------------------------------------


func _load_rooms() -> void:
	print_debug("[ProcGenLevelTest] _load_rooms()")
	_rooms_folder = Directory.new()

	@warning_ignore(return_value_discarded)
	_rooms_folder.open(rooms_folder_path)

	@warning_ignore(return_value_discarded)
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
	print_debug("[ProcGenLevelTest] _set_initial_room()")
	if specify_initial_room:
		_initial_room = specify_initial_room
	else:
		_initial_room = _rooms_list[randi() % _rooms_list.size()]
	_initial_room_instance = _initial_room.instantiate()
	await Signal(get_tree().physics_frame)
	self.add_child(_initial_room_instance)
	_rooms_in_tree.append(_initial_room_instance)


func _build_room_tree() -> void:
	print_debug("[ProcGenLevelTest] _build_room_tree()")

	var index: int = 0+1+1  # initial room and final room must be counted!
	var blacklisted_source_rooms: Array = []

	await Signal(get_tree().physics_frame)  # this is here to avoid "First argument of yield() not of type object."
	while index <= number_of_rooms:
		print_debug("[ProcGenLevelTest] _build_room_tree() : index=" + str(index))

		# Select a random room in the room tree.
		var selected_room: ProceduralRoomController = _rooms_in_tree[randi() % _rooms_in_tree.size()]

		# If the source room (instance) is blacklisted, continue.
		if selected_room in blacklisted_source_rooms:
			continue

		var inner_success = false
		var inner_index = 0
		var inner_limit = 5
		var appending_error = 3
		var appending_room_instance: ProceduralRoomController = null
		var blacklisted_inner_rooms: Array = []

		# Keep trying to fit a new room around the current non-blacklisted room
		# Until we succeed or run out of attempts.
		while not(inner_success) and inner_index < inner_limit:
			print_debug("[ProcGenLevelTest] _build_room_tree() : inner_index=" + str(inner_index))

			# Select a random room from the room list.
			var appending_room = _rooms_list[randi() % _rooms_list.size()]

			# If appending room (scene) has been previously blacklisted, continue.
			if appending_room in blacklisted_inner_rooms:
				inner_index += 1
				continue
			
			# Try appending rooms.
			var result = await _append_rooms(selected_room, appending_room)
			appending_room_instance = result["room"]
			appending_error = result["error"]
			if appending_error == 1:  # no available joints, blacklist the selected room!
				blacklisted_source_rooms.append(selected_room)
				break
			elif appending_error == 2:  # no available space, try again the inner cycle
				blacklisted_inner_rooms.append(appending_room)
				inner_index += 1
			elif appending_error == 0:  # success!
				_rooms_in_tree.append(appending_room_instance)
				inner_success = true
				index += 1

		
func _append_rooms(source_room: Node2D, target_room_scene: PackedScene) -> Variant:
	print_debug("[ProcGenLevelTest] _append_rooms()")

	# Instance target room
	var target_room: ProceduralRoomController = target_room_scene.instantiate()
	await Signal(get_tree().physics_frame)  # this is here to avoid "First argument of yield() not of type object."

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
		return {"room": null, "error": no_available_joints_error}

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
		if target_joint == null:
			# no compatible joint has been found in this target room!
			return {"room": null, "error": no_space_error}
	else:
		return {"room": null, "error": no_space_error}
	
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
	var target_joint_global_position : Vector2 = Vector2.ZERO
	if is_instance_valid(target_room) and is_instance_valid(target_joint):	# (because of all the yields!)
		target_joint_global_position = target_joint.global_position
		target_room.global_position = source_joint_global_position - target_joint_global_position + offset
	else:
		return {"room": null, "error": no_space_error}

	# Check for collisions with all the rooms of the tree
	# TODO this should be changed, should check only "neighbours"... maybe it would be costly though
	await Signal(get_tree().physics_frame)
	var target_collider: ProceduralCollider = null
	if is_instance_valid(target_room):	# (because of all the yields!)
		target_collider	= target_room.get_node("ProceduralCollider")
	else:
		await Signal(get_tree().physics_frame)
		return no_space_error
	for room in _rooms_in_tree:
		var room_collider: ProceduralCollider = room.get_node("ProceduralCollider")
		await Signal(get_tree().physics_frame)
		if (target_collider in room_collider.get_overlapping_areas()) or (room_collider in target_collider.get_overlapping_areas()):
			target_room.queue_free()
			return {"room": null, "error": no_space_error}
	
	# Everything's good!
	source_joint.is_jointed = true
	target_joint.is_jointed = true
	return {"room": target_room, "error": success}  # success!


func _set_final_room() -> void:
	print_debug("[ProcGenLevelTest] _set_final_room()")

	await Signal(get_tree().physics_frame)  # this is here to avoid "First argument of yield() not of type object."
	_final_room_instance = null
	if specify_final_room:
		_final_room = specify_final_room
	else:
		_final_room = _rooms_list[randi() % _rooms_list.size()]
	var success = false
	while not(success):
		var selected_room: Node2D = _rooms_in_tree[randi() % _rooms_in_tree.size()]
		var result = await _append_rooms(selected_room, _final_room)
		var appending_error = result["error"]
		_final_room_instance = result["room"]
		success = (appending_error == 0)
	_rooms_in_tree.append(_final_room_instance)


func _close_all_unused_joints() -> void:
	for room in _rooms_in_tree:
		room.close_unused_joints()


func _deactivate_all_areas() -> void:
	print_debug("[ProcGenLevelTest] _deactivate_all_areas()")

	await Signal(get_tree().physics_frame)  # wait a bit!
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
	print_debug("[ProcGenLevelTest] _spawn_player()")

	var player_instance: Node2D = player_model.instantiate()
	self.add_child(player_instance)
	player_instance.position = _initial_room_instance.get_node("SpawnPosition").position
