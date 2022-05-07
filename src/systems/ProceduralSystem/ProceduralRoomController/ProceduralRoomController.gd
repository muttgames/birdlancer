@tool
extends Node2D
class_name ProceduralRoomController


@export var wall_tilemap_nodepath: NodePath
@export var tilemap_source_id: int
@export var tilemap_layer_number: int
# @export var tilemap_terrain_set: int
@export var tilemap_horizontal_closed_pattern_index: int
@export var tilemap_vertical_closed_pattern_index: int

# maybe there should be a ProceduralJointContainer class?


func close_unused_joints() -> Array:

	var unused_joints_coordinates_array := []

	var joints: Node2D = get_node("Joints")
	var wall_tilemap: TileMap = get_node(wall_tilemap_nodepath)

	for joint in joints.get_children():
		if not(joint.is_jointed):
			var joint_coordinates: Vector2 = joint.position  # ! remember that these coordinates are CENTERED!
			print_debug("[ProceduralRoomController] joint_coordinates: ", joint_coordinates)
			unused_joints_coordinates_array.append(joint_coordinates)

			var cell_size = Vector2(1, 1)*wall_tilemap.get_quadrant_size()  # should be equal to Globals.GRID_SIZE
			assert(cell_size == Globals.GRID_SIZE)

			if joint.joint_position in [0, 2]:  # North or South, means it's horizontal
				var joint_tilemap_coordinates = wall_tilemap.world_to_map(Vector2(joint_coordinates.x-Globals.JOINT_SIZE.x/4, joint_coordinates.y))
				print_debug("[ProceduralRoomController] Horizontal joint_tilemap_coordinates: ", joint_tilemap_coordinates)
				var cell_coord: Vector2i = Vector2i(joint_tilemap_coordinates.x, joint_tilemap_coordinates.y)
				
				var horizontal_closed_pattern: TileMapPattern
				if joint.force_tilemap_closed_pattern_index!=0 and joint.force_tilemap_closed_pattern_index!=null:
					horizontal_closed_pattern = wall_tilemap.get_tileset().get_pattern(joint.force_tilemap_closed_pattern_index)
				else:
					horizontal_closed_pattern = wall_tilemap.get_tileset().get_pattern(tilemap_horizontal_closed_pattern_index)
				assert(horizontal_closed_pattern.get_size().x%2==0, "The horizontal pattern must have an even number to work correctly!")
				var pattern_offset: Vector2i = cell_coord+Vector2i(-int(horizontal_closed_pattern.get_size().x/4), 0)
				wall_tilemap.set_pattern(tilemap_layer_number, pattern_offset, horizontal_closed_pattern)

				# var cells_array: Array[Vector2i] = [cell_coord+Vector2i(-1, 0), cell_coord, cell_coord+Vector2i(1, 0), cell_coord+Vector2i(2, 0)]
				# wall_tilemap.set_cells_from_surrounding_terrains(tilemap_layer_number, cells_array, tilemap_terrain_set, true)
				
				# var prev_cell_atlas_coord = wall_tilemap.get_cell_atlas_coords(tilemap_layer_number, Vector2i(joint_tilemap_coordinates.x-1, joint_tilemap_coordinates.y), false)
				# wall_tilemap.set_cell(tilemap_layer_number, Vector2i(joint_tilemap_coordinates.x, joint_tilemap_coordinates.y), tilemap_source_id, prev_cell_atlas_coord)
				# wall_tilemap.set_cell(tilemap_layer_number, Vector2i(joint_tilemap_coordinates.x+1, joint_tilemap_coordinates.y), tilemap_source_id, prev_cell_atlas_coord)
			
			elif joint.joint_position in [1, 3]:  # East or West, means it's vertical
				var joint_tilemap_coordinates = wall_tilemap.world_to_map(Vector2(joint_coordinates.x, joint_coordinates.y-Globals.JOINT_SIZE.y/4))
				print_debug("[ProceduralRoomController] Vertical joint_tilemap_coordinates: ", joint_tilemap_coordinates)
				var cell_coord: Vector2i = Vector2i(joint_tilemap_coordinates.x, joint_tilemap_coordinates.y)

				var vertical_closed_pattern: TileMapPattern
				if joint.force_tilemap_closed_pattern_index!=0 and joint.force_tilemap_closed_pattern_index!=null:
					vertical_closed_pattern = wall_tilemap.get_tileset().get_pattern(joint.force_tilemap_closed_pattern_index)
				else:
					vertical_closed_pattern = wall_tilemap.get_tileset().get_pattern(tilemap_vertical_closed_pattern_index)
				assert(vertical_closed_pattern.get_size().y%2==0, "The vertical pattern must have an even number of cells to work correctly!")
				var pattern_offset: Vector2i = cell_coord+Vector2i(0, -int(vertical_closed_pattern.get_size().y/4))
				wall_tilemap.set_pattern(tilemap_layer_number, pattern_offset, vertical_closed_pattern)

				# var cells_array: Array[Vector2i] = [cell_coord+Vector2i(0, -1), cell_coord, cell_coord+Vector2i(0, 1), cell_coord+Vector2i(0, 2)]
				# wall_tilemap.set_cells_from_surrounding_terrains(tilemap_layer_number, cells_array, tilemap_terrain_set, true)
				
				# var prev_cell_atlas_coord = wall_tilemap.get_cell_atlas_coords(tilemap_layer_number, Vector2i(joint_tilemap_coordinates.x, joint_tilemap_coordinates.y-1), false)
				# wall_tilemap.set_cell(tilemap_layer_number, Vector2i(joint_tilemap_coordinates.x, joint_tilemap_coordinates.y), tilemap_source_id, prev_cell_atlas_coord)
				# wall_tilemap.set_cell(tilemap_layer_number, Vector2i(joint_tilemap_coordinates.x, joint_tilemap_coordinates.y+1), tilemap_source_id, prev_cell_atlas_coord)
				
			wall_tilemap.force_update(tilemap_layer_number)

	return unused_joints_coordinates_array


func _get_configuration_warning() -> String:
	if wall_tilemap_nodepath == null:
		return "wall_tilemap_nodepath needs to be assigned a TileMap Node2D!"
	if tilemap_source_id == null:
		return "tilemap_source_id needs to be assigned an int!"
	if tilemap_layer_number == null:
		return "tilemap_layer_number needs to be assigned an int!"
	if tilemap_horizontal_closed_pattern_index == null:
		return "tilemap_horizontal_closed_pattern_index needs to be assigned an int!"
	if tilemap_vertical_closed_pattern_index == null:
		return "tilemap_vertical_closed_pattern_index needs to be assigned an int!"

	return ""
