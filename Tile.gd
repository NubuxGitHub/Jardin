extends Node2D

class_name Tile

var map_coord : Vector2i
#var hp : int
#var cell_data : Dictionary = {
#
#}
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


func gather_seed(pos :Vector2i)->void:
	var seed :int = tile_map.get_cell_atlas_coords(CNST.LAYER_OBJECTS,pos).y
	match seed:
		
		1:
			Autoload.update_seed_library("marais", +1)
			tile_map.erase_cell(CNST.LAYER_OBJECTS,pos)
		2:
			Autoload.update_seed_library("prairie", +1)
			tile_map.erase_cell(CNST.LAYER_OBJECTS,pos)
		3:
			Autoload.update_seed_library("foret", +1)
			tile_map.erase_cell(CNST.LAYER_OBJECTS,pos)
		_:
			pass


func count_surrounding_same_tiles(center_tile:Vector2i, type:int)->int:
	var surround :Array = tile_map.get_surrounding_cells(center_tile)
	var counter :int = 0
	for cell in surround:
# on compte le nombre de tuiles voisine qui sont  du meme type 
		if  check_type(cell) == type:
			counter += 1
	return counter


func set_terrain_cell (
	processed_cell :Vector2i,
	type :int,
	layer_id :int = CNST.LAYER_TERRAIN,
	tileset_id :int= CNST.TERRAIN_TSET 
	):
		
	var x_rnd_sprite = randi_range(0,2)
	tile_map.set_cell(layer_id,processed_cell,tileset_id,Vector2i(x_rnd_sprite,type))
