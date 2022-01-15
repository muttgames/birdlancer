tool
extends Node2D
class_name ProceduralRoomController


export(NodePath) var wall_tilemap_nodepath: NodePath


# ? maybe there should be a ProceduralJointContainer class?


func close_unused_joints() -> void:
	var joints: Node2D = get_node("Joints")
	var wall_tilemap: TileMap = get_node(wall_tilemap_nodepath)

	for joint in joints.get_children():
		if not(joint.is_jointed):
			var joint_coordinates = joint.position  # ! remember that these coordinates are CENTERED!

			var cell_size = wall_tilemap.cell_size  # should be equal to Globals.GRID_SIZE
			assert(cell_size == Globals.GRID_SIZE)
			# also check again that JOINT_SIZE is a multiple of GRID_SIZE
			assert(fmod(Globals.JOINT_SIZE.x, Globals.GRID_SIZE.x) == 0) 
			assert(fmod(Globals.JOINT_SIZE.y, Globals.GRID_SIZE.y) == 0) 

			if joint.joint_position in [0, 2]:  # North or South, means it's horizontal
				var joint_tilemap_coordinates = wall_tilemap.world_to_map(Vector2(joint_coordinates.x-Globals.JOINT_SIZE.x/4, joint_coordinates.y))
				wall_tilemap.set_cell(joint_tilemap_coordinates.x, joint_tilemap_coordinates.y, 3)
				wall_tilemap.set_cell(joint_tilemap_coordinates.x+1, joint_tilemap_coordinates.y, 3)
			elif joint.joint_position in [1, 3]:  # East or West, means it's vertical
				var joint_tilemap_coordinates = wall_tilemap.world_to_map(Vector2(joint_coordinates.x, joint_coordinates.y-Globals.JOINT_SIZE.x/4))
				wall_tilemap.set_cell(joint_tilemap_coordinates.x, joint_tilemap_coordinates.y, 3)
				wall_tilemap.set_cell(joint_tilemap_coordinates.x, joint_tilemap_coordinates.y+1, 3)		
			wall_tilemap.update_bitmask_region()


func _get_configuration_warning() -> String:
	if wall_tilemap_nodepath == null:
		return "wall_tilemap_nodepath needs to be assigned a TileMap Node2D!"

	return ""
