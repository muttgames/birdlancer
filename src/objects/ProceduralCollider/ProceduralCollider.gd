tool
extends Area2D
class_name ProceduralCollider


export(NodePath) var tilemap_nodepath: NodePath
export(float, 0, 1, 0.01) var horizontal_coverage_coefficient: float = 0.95
export(float, 0, 1, 0.01) var vertical_coverage_coefficient: float = 0.95


var _tilemap: TileMap
var _used_rect: Rect2
var _tilemap_cell_size: Vector2


func _process(_delta: float) -> void:
	if tilemap_nodepath:
		_tilemap = get_node(tilemap_nodepath)
		if _tilemap:
			_used_rect = _tilemap.get_used_rect()
			_tilemap_cell_size = _tilemap.get_cell_size()
			self.position = (_used_rect.position+_used_rect.end)*_tilemap_cell_size/2

			self.scale = _used_rect.size*_tilemap_cell_size/2
			self.scale.x *= horizontal_coverage_coefficient
			self.scale.y *= vertical_coverage_coefficient

			# The #_coverage_coefficient is used because otherwise the rectangle would cover
			# everything to the very edge, and touching edges are counted as
			# overlapping areas, so there would be lots of false positives
