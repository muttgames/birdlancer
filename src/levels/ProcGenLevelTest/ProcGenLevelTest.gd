extends Node2D

export(String) var rooms_folder_path: String = "res://src/levels/ProcGenLevelTest/Rooms/"
export(PackedScene) var player_model: PackedScene

var _rooms_list: Array
var _rooms_folder: Directory

func _ready() -> void:
	_rooms_folder = Directory.new()

	#ignore-warning:return_value_discarded
	_rooms_folder.open(rooms_folder_path)

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
	
	var initial_room: Node2D = _rooms_list[randi() % _rooms_list.size()].instance()
	self.add_child(initial_room)

	var player_instance: Node2D = player_model.instance()
	var camera_2D: Camera2D = Camera2D.new()
	camera_2D.name = "Camera2D"
	camera_2D.current = true
	player_instance.add_child(camera_2D)
	self.add_child(player_instance)
	player_instance.position = initial_room.get_node("SpawnPosition").position
