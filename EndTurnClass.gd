extends Node
class_name EndTurn

var tile_map:TileMap

var TileClass = Tile.new()



func get_tilemap(tilemap:TileMap):
	tile_map = tilemap
	TileClass.get_tilemap(tilemap)



func grow_planted_seeds(planted_tiles :Array[Vector2i]):
	for pl_tile in planted_tiles:
		var tile_type = TileClass.check_type(pl_tile)
		match tile_type:
			CNST.TERRE:
#				tile_map.set_cell(CNST.LAYER_TERRAIN,pl_tile,0,Vector2i(0,CNST.MARAIS))
				TileClass.set_terrain_cell(pl_tile,CNST.MARAIS)
			CNST.MARAIS:
				TileClass.set_terrain_cell(pl_tile,CNST.PRAIRIE)
#				tile_map.set_cell(CNST.LAYER_TERRAIN,pl_tile,0,Vector2i(0,CNST.PRAIRIE))
			CNST.PRAIRIE:
#				tile_map.set_cell(CNST.LAYER_TERRAIN,pl_tile,0,Vector2i(0,CNST.FORET))
				TileClass.set_terrain_cell(pl_tile,CNST.FORET)
		tile_map.erase_cell(CNST.LAYER_OBJECTS,pl_tile)


func generate_seeds_from_megatiles()->void:
# chaque megaMarais(Autoload.mega_tile_tracking[0]) genere une graine "prairie"
# chaque megaPrairie (Autoload.mega_tile_tracking[1]) genere une graine "foret"
# chaque megaForet(Autoload.mega_tile_tracking[2]) genere une graine "marais"
		Autoload.update_seed_library("prairie", + Autoload.mega_tile_tracking[0])
		Autoload.update_seed_library("foret", + Autoload.mega_tile_tracking[1])
		Autoload.update_seed_library("marais", +Autoload.mega_tile_tracking[2])
#	for seed in mega_tile_centers:
#		var mega_type :int = tile_map.get_cell_source_id(0,seed)
#		match mega_type :
#			CNST.MEGA_MARAIS_TSET :
#				tile_map.set_cell(CNST.LAYER_OBJECTS,seed,CNST.OBJECTS_TSET,Vector2i(0,2))
#			CNST.MEGA_PRAIRIE_TSET:
#				tile_map.set_cell(CNST.LAYER_OBJECTS,seed,CNST.OBJECTS_TSET,Vector2i(0,3))
#			CNST.MEGA_FORET_TSET:
#				tile_map.set_cell(CNST.LAYER_OBJECTS,seed,CNST.OBJECTS_TSET,Vector2i(0,3))



## retourne un Vector2i dont
## x = le nombre de types hostiles differents,
## y = total des tuiles hostiles
func count_life_and_death( types:Array[int], alignement:String)->Vector2i:
	var total: Array = []
	var x_variety_count:int = 0
	match alignement:
		"life":
			for type in types:
				if type > CNST.TERRE and type < CNST.VILLE:
					if  not total.has(type):
						x_variety_count += 1
					total.append(type)
		"death":
			for type in types:
				if type >= CNST.VILLE:
					if  not total.has(type):
						x_variety_count += 1
					total.append(type)
	var y_total :int = total.size()
	return Vector2i(x_variety_count,y_total)

