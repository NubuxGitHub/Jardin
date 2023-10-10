extends Node2D

class_name Tile

var map_coord : Vector2i
var hp : int
#var terrain_layer :int = 0
var tile_map :TileMap

func get_tilemap(tilemap:TileMap):
	tile_map = tilemap


func check_type(coords :Vector2i) -> int:
	var type :int = tile_map.get_cell_atlas_coords(0,coords).y
	if tile_map.get_cell_source_id(0,coords) == 100 and type >= 0 :
		type +=100
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

