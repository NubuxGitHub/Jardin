extends Node2D

#signal location_changed(Vector2i)


signal player_moved
#  Les valeurs des terrain correspondent à la valeur.y 
# de l'atlas_coordinates du tileset "terrain"(ID : 0)
# la valeur.x correspondant aux differentes variantes du meme type de terrain.
enum {
	EMPTY   = -1,
	TERRE   = 0,
	MARAIS  = 1,
	PRAIRIE = 2,
	FORET   = 3,
	VILLE   = 100,
	POUBELLE= 101,
	DESASTRE= 102,
}

enum MEGATUILE {
	MEGA_MARAIS  = 1,
	MEGA_PRAIRIE = 2,
	MEGA_FORET   = 3,
}
#@export var region_size = 25

var harvested_tiles :Array[Vector2i] = []
var planted_tiles   :Array[Vector2i] = []

var mega_prairie :Array[Vector2i] = []
var mega_foret   :Array[Vector2i] = []
var mega_marais  :Array[Vector2i] = []
var mega_tile_centers :Array[Vector2i]=[]
var mouse_map_pos: Vector2i

@onready var player := $Player
@onready var tile_map := $TileMap
@onready var GUI = $GUI

#var tile_changed :Vector2i = Vector2i.ZERO:
#	set(value):
#		if value != tile_changed:
#			emit_signal("location_changed",value)
#		tile_changed = value
#	get:
#		return tile_changed

var player_map_pos :Vector2i

var get_terrain_type :Callable = func(cell)->int:
	var type :int = tile_map.get_cell_atlas_coords(0,cell).y
	if tile_map.get_cell_source_id(0,cell) == 100 and type >= 0 :
		type +=100
	return type


func _ready():
	Autoload.turn_ended.connect(on_turn_ended)
	Autoload.update_seed_library("marais", +20)
	player_moved.connect(player.on_player_moved)


func _unhandled_input(event):
	if Input.is_action_just_pressed("place_player"):
		player.position = tile_map.map_to_local(mouse_map_pos)
		emit_signal("player_moved",player.global_position)
		
	if Input.is_action_just_pressed("right_click"):
		var terrain_under_player :int = get_terrain_type.call(player_map_pos)
		if count_surrounding_same_tiles(player_map_pos,terrain_under_player) == 6:
			var surround :Array[Vector2i]= tile_map.get_surrounding_cells(player_map_pos)
			surround.append(player_map_pos)
#			fx_rise_tiles(surround)
			match terrain_under_player:
				TERRE:
					harvest_seed(surround)
				PRAIRIE:
					build_megatile(surround,player_map_pos,PRAIRIE)
				FORET:
					build_megatile(surround,player_map_pos,FORET)
				MARAIS:
					build_megatile(surround,player_map_pos,MARAIS)
	
	if Input.is_action_just_pressed("planter_ramasser"):
		if Autoload.seed_library.marais >= 1:
			gather_or_plant_seed()
	
	if Input.is_action_pressed("quit_game"):
		get_tree().quit()
	
	if Input.is_action_pressed("ui_accept"):
		Autoload.emit_signal("turn_ended")


func _process(delta):
	player_map_pos = tile_map.local_to_map(player.global_position)
#	tile_changed = player_map_pos
	GUI.debug_label(mouse_map_pos)
	mouse_map_pos = tile_map.local_to_map(get_global_mouse_position())


func on_turn_ended()->void:
#	reset harvested tiles
	for harv_tile in harvested_tiles:
		tile_map.set_cell(0,harv_tile,0,Vector2i(0,0))
#	planted tiles devient prairie
	for pl_tile in planted_tiles:
		tile_map.set_cell(0,pl_tile,0,Vector2i(0,1))
		tile_map.erase_cell(1,pl_tile)
	harvested_tiles.clear()
	planted_tiles.clear()
	process_all_region_tiles()
	generate_seeds_frome_megatiles()


func count_surrounding_same_tiles(center_tile:Vector2i, type:int)->int:
	var surround :Array = tile_map.get_surrounding_cells(center_tile)
	var counter :int = 0
	for cell in surround:
# on compte le nombre de tuiles voisine qui sont  du meme type 
		if  get_terrain_type.call(cell) == type:
			counter += 1
	return counter


## détruit les tuiles du groupe et place une Megatuile
func build_megatile(surround, center_tile, type)->void:
# detruire
	for destroyable in surround:
		tile_map.erase_cell(0,destroyable)
# construire
	var megatuile:int
	var add_to_terrain_type_array :Callable = func(type_array :Array[Vector2i]):
		for tile in surround:
			type_array.append(tile)
	
	match type:
		MARAIS:
			megatuile = MEGATUILE.MEGA_MARAIS# ID du tileset megatuile Marais
			add_to_terrain_type_array.call(mega_marais)
		PRAIRIE:
			megatuile = MEGATUILE.MEGA_PRAIRIE# ID du tileset megatuile prairie
			add_to_terrain_type_array.call(mega_prairie)
		FORET:
			megatuile = MEGATUILE.MEGA_FORET# ID du tileset megatuile Forets
			add_to_terrain_type_array.call(mega_foret)
	tile_map.set_cell(0,center_tile,megatuile,Vector2i.ZERO)
	mega_tile_centers.append(center_tile)


func harvest_seed(surround)->void:
	var harvestable :int = 0
	var new_harvested_tiles :Array[Vector2i]=[]
	for each in surround:
		if harvested_tiles.has(each):
			break
		else: 
			new_harvested_tiles.append(each)
			harvestable += 1
#	print("-----","\nharvestables = ",harvestable,"\n new harvested tiles = ",\
#	new_harvested_tiles, "\n harvested _tiles = ", harvested_tiles)
# genere la graine 
	if harvestable == 7:
			Autoload.update_seed_library("marais", +1)
			harvested_tiles.append_array(new_harvested_tiles)
#			Change l'image de la tile harvested
			for tile in new_harvested_tiles:
				tile_map.set_cell(0,tile,0,Vector2i(3,0))


func gather_or_plant_seed()->void:
#	plant :
	if get_terrain_type.call(player_map_pos) == TERRE and not planted_tiles.has(player_map_pos):
#		print ("graine plantée")
		planted_tiles.append(player_map_pos)
		Autoload.update_seed_library("marais",-1)
		tile_map.set_cell(1,player_map_pos,4,Vector2i.ZERO)


func process_all_region_tiles()->void:
	var all_terrain_tiles :Array[Vector2i] = tile_map.get_used_cells(0)
	# ----------------LAMBDAS FUNCS: ---------------------
	## recolte des infos sur les tuiles entourant la tuile choisie
	var get_surrounding_types :Callable = func(surround)->Array :
		var type :Array[int]=[]
		var mega_type :Array[String]=[]
		var combined_array :Array =[]
		for i in surround:
		# build type array:
			var get_type :int = get_terrain_type.call(i)
			if get_type >= 1:
				type.append(get_type)
		# build  mega-type array:
			if  mega_prairie.has(i):mega_type.append("mega_prairie")
			if  mega_foret.has(i):  mega_type.append("mega_foret")
			if mega_marais.has(i):  mega_type.append("mega_marais")
		#return combined arrays:
		combined_array.append(type)
		combined_array.append(mega_type)
		return combined_array


	# ------------------PROCESS:-------------
	for processed_cell in all_terrain_tiles:
		var type :int = 0
		var mega_type: int = 1
		
		var processed_type :int = get_terrain_type.call(processed_cell)
		var surrounding_tiles :Array[Vector2i] = tile_map.get_surrounding_cells(processed_cell)
		var surrounding_types :Array = get_surrounding_types.call(surrounding_tiles)

		if processed_type >= 1: 
			match processed_type:
				PRAIRIE:
					if  surrounding_types[mega_type].has("mega_prairie"):
						print(processed_cell, " est voisin d'une megaprairie ")
				FORET:
					if  surrounding_types[mega_type].has("mega_foret"):
						print(processed_cell, " est voisin d'une megaforet")
				MARAIS:
					pass
				VILLE:
					pass
				POUBELLE:
					pass
				DESASTRE:
					pass
#		print("types around ",processed_cell," = ",surrounding_types)


func generate_seeds_frome_megatiles()->void:
	for seed in mega_tile_centers:
		var mega_type :int = tile_map.get_cell_source_id(0,seed)
		match mega_type :
			MEGATUILE.MEGA_MARAIS :
				tile_map.set_cell(1,seed,4,Vector2i(1,0))
			MEGATUILE.MEGA_PRAIRIE :
				tile_map.set_cell(1,seed,4,Vector2i(2,0))
			MEGATUILE.MEGA_FORET:
				tile_map.set_cell(1,seed,4,Vector2i(2,0))


#func fx_rise_tiles(tiles :Array[Vector2i]= [])->void:
#	if tiles != []:
#		for tile in tiles:
#			var tile_data :TileData = tile_map.get_cell_tile_data(0,tile)
#			tile_data.texture_origin.y += 10
#func get_cluster()->Array[Vector2i]:
#	var cluster: Array[Vector2i] = []
#	cluster.append(tile_map.get_surrounding_cells(player_map_pos))
#	cluster.append(player_map_pos)
#	return cluster
