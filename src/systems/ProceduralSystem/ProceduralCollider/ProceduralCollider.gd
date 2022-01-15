tool
extends Area2D
class_name ProceduralCollider


export(NodePath) var tilemap_nodepath: NodePath
export(bool) var convex_hull_mode: bool = false


var _tilemap: TileMap
var _used_rect: Rect2
var _tilemap_cell_size: Vector2
var _used_cells: Array
var _used_cells_position_array: Array
var _center_of_used_cells_position_array: Vector2


onready var _collision_polygon_2D: CollisionPolygon2D = $CollisionPolygon2D


func _ready() -> void:
	_build_collisions()


func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		# https://docs.godotengine.org/it/stable/classes/class_engine.html
		_build_collisions()
	

func _build_collisions() -> void:
	if tilemap_nodepath:
		_tilemap = get_node(tilemap_nodepath)
		if _tilemap:
			_used_rect = _tilemap.get_used_rect()
			_used_cells = _tilemap.get_used_cells()
			_tilemap_cell_size = _tilemap.get_cell_size()
			
			self.position = _used_rect.position

			_used_cells_position_array = []
			for cell_vector in _used_cells:
				_used_cells_position_array.append(_get_tile_center_position(cell_vector, _tilemap_cell_size))
			
			_center_of_used_cells_position_array = _center_of_vector2_array(_used_cells_position_array)
			_used_cells_position_array.sort_custom(self, "_sort_clockwise")

			var pooled_array: PoolVector2Array = PoolVector2Array(_used_cells_position_array)
			if convex_hull_mode:
				_collision_polygon_2D.set_polygon(Geometry.convex_hull_2d(pooled_array))
			else:
				_collision_polygon_2D.set_polygon(pooled_array)


func _get_tile_center_position(tile_pos: Vector2, cell_size: Vector2) -> Vector2:
	var tile_center_pos: Vector2 = _tilemap.map_to_world(tile_pos) + cell_size / 2
	return tile_center_pos


func _sort_clockwise(a, b) -> bool:
	return (a - _center_of_used_cells_position_array).angle() < (b - _center_of_used_cells_position_array).angle()


func _center_of_vector2_array(array) -> Vector2:
	var sum_x = 0.0
	var sum_y = 0.0
	for element in array:
			sum_x += element.x
			sum_y += element.y
	var center = Vector2(sum_x/len(array), sum_y/len(array))
	return center