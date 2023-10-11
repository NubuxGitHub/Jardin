extends Node2D

class_name Tile

var map_coord : Vector2i
var hp : int
var cell_data : Dictionary = {
	
}
var tile_map :TileMap


func get_tilemap(tilemap:TileMap):
	tile_map = tilemap


func check_type(cords :Vector2i) -> int:
	var type :int = tile_map.get_cell_atlas_coords(CNST.LAYER_TERRAIN,cords).y
	if type >= 0 :
		var check_tileset = tile_map.get_cell_source_id(CNST.LAYER_TERRAIN,cords)
		match check_tileset:
			CNST.MEGA_MARAIS_TSET:
				type = CNST.MEGA_MARAIS_TSET
			CNST.MEGA_PRAIRIE_TSET:
				type = CNST.MEGA_PRAIRIE_TSET
			CNST.MEGA_FORET_TSET:
				type = CNST.MEGA_FORET_TSET
			CNST.DEATH_TSET:
				type += CNST.DEATH_TSET
#	print ("apres: ",cords," = ",type)
#	if cords == Vector2i(6,2):
#		print (cords," = ",type)
#		print ("avant : ",tile_map.get_cell_source_id(0,cords))
	return type
#
#func suround(position:Vector2i)->Array[Vector2i]:
#	return tile_map.get_surrounding_cells(position)



func count_surrounding_same_tiles(center_tile:Vector2i, type:int)->int:
	var surround :Array = tile_map.get_surrounding_cells(center_tile)
	var counter :int = 0
	for cell in surround:
# on compte le nombre de tuiles voisine qui sont  du meme type 
		if  check_type(cell) == type:
			counter += 1
	return counter

