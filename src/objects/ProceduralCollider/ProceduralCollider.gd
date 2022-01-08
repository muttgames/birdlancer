tool
extends Area2D
class_name ProceduralCollider


export(NodePath) var tilemap_nodepath: NodePath


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
			self.scale = 0.9*_used_rect.size*_tilemap_cell_size/2
			# The 0.9 is used because otherwise the rectangle would cover
			# everything to the very edge, and touching edges are counted as
			# overlapping areas, so there would be lots of false positives
