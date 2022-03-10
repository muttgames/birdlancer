@tool
extends Node2D
class_name ProceduralRoomController


const TILEMAP_LAYER_NUMBER := 0  # TODO
const TILEMAP_SOURCE_ID := 6  # TODO
const TILEMAP_TERRAIN_SET := 0  # TODO


@export var wall_tilemap_nodepath: NodePath


# ? maybe there should be a ProceduralJointContainer class?


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
				var prev_cell_atlas_coord = wall_tilemap.get_cell_atlas_coords(TILEMAP_LAYER_NUMBER, Vector2i(joint_tilemap_coordinates.x-1, joint_tilemap_coordinates.y), false)
				wall_tilemap.set_cell(TILEMAP_LAYER_NUMBER, Vector2i(joint_tilemap_coordinates.x, joint_tilemap_coordinates.y), TILEMAP_SOURCE_ID, prev_cell_atlas_coord)
				wall_tilemap.set_cell(TILEMAP_LAYER_NUMBER, Vector2i(joint_tilemap_coordinates.x+1, joint_tilemap_coordinates.y), TILEMAP_SOURCE_ID, prev_cell_atlas_coord)
			
			elif joint.joint_position in [1, 3]:  # East or West, means it's vertical
				var joint_tilemap_coordinates = wall_tilemap.world_to_map(Vector2(joint_coordinates.x, joint_coordinates.y-Globals.JOINT_SIZE.y/4))
				print_debug("[ProceduralRoomController] Vertical joint_tilemap_coordinates: ", joint_tilemap_coordinates)
				var prev_cell_atlas_coord = wall_tilemap.get_cell_atlas_coords(TILEMAP_LAYER_NUMBER, Vector2i(joint_tilemap_coordinates.x, joint_tilemap_coordinates.y-1), false)
				wall_tilemap.set_cell(TILEMAP_LAYER_NUMBER, Vector2i(joint_tilemap_coordinates.x, joint_tilemap_coordinates.y), TILEMAP_SOURCE_ID, prev_cell_atlas_coord)
				wall_tilemap.set_cell(TILEMAP_LAYER_NUMBER, Vector2i(joint_tilemap_coordinates.x, joint_tilemap_coordinates.y+1), TILEMAP_SOURCE_ID, prev_cell_atlas_coord)
				
			wall_tilemap.force_update(TILEMAP_LAYER_NUMBER)

	return unused_joints_coordinates_array


func _get_configuration_warning() -> String:
	if wall_tilemap_nodepath == null:
		return "wall_tilemap_nodepath needs to be assigned a TileMap Node2D!"

	return ""
