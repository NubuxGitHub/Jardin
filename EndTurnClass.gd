extends Node
class_name EndTurn

var tile_map:TileMap

var TileClass = Tile.new()



func get_tilemap(tilemap:TileMap):
	tile_map = tilemap
	TileClass.get_tilemap(tilemap)



func grow_planted_seeds(planted_tiles :Array[Vector2i]):
	for pl_tile in planted_tiles:
		match TileClass.check_type(pl_tile):
			CNST.TERRE:
				tile_map.set_cell(CNST.LAYER_TERRAIN,pl_tile,0,Vector2i(0,CNST.MARAIS))
			CNST.MARAIS:
				tile_map.set_cell(CNST.LAYER_TERRAIN,pl_tile,0,Vector2i(0,CNST.PRAIRIE))
			CNST.PRAIRIE:
				tile_map.set_cell(CNST.LAYER_TERRAIN,pl_tile,0,Vector2i(0,CNST.FORET))
		tile_map.erase_cell(CNST.LAYER_OBJECTS,pl_tile)


func generate_seeds_from_megatiles(mega_tile_centers :Array[Vector2i])->void:
	for seed in mega_tile_centers:
		var mega_type :int = tile_map.get_cell_source_id(0,seed)
		match mega_type :
			CNST.MEGA_MARAIS :
				tile_map.set_cell(CNST.LAYER_OBJECTS,seed,4,Vector2i(1,0))
			CNST.MEGA_PRAIRIE:
				tile_map.set_cell(CNST.LAYER_OBJECTS,seed,4,Vector2i(2,0))
			CNST.MEGA_FORET:
				tile_map.set_cell(CNST.LAYER_OBJECTS,seed,4,Vector2i(2,0))
