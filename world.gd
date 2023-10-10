extends Node2D

#signal location_changed(Vector2i)


signal player_moved
#  Les valeurs des terrain correspondent à la valeur.y 
# de l'atlas_coordinates du tileset "terrain"(ID : 0)
# la valeur.x correspondant aux differentes variantes du meme type de terrain.
#enum {
#	EMPTY   = -1,
#	TERRE   = 0,
#	MARAIS  = 1,
#	PRAIRIE = 2,
#	FORET   = 3,
#	VILLE   = 100,
#	POUBELLE= 101,
#	DESASTRE= 102,
#}
#
#enum MEGATUILE {
#	MARAIS  = 1,
#	PRAIRIE = 2,
#	FORET   = 3,
#}
##@export var region_size = 25
#enum LAYERS {
#	TERRAIN=0,
#	OBJECTS=1,
#}


var harvested_tiles :Array[Vector2i] = []
var planted_tiles   :Array[Vector2i] = []

var mega_prairie :Array[Vector2i] = []
var mega_foret   :Array[Vector2i] = []
var mega_marais  :Array[Vector2i] = []
var mega_tile_centers :Array[Vector2i]=[]
var mouse_map_pos: Vector2i

@onready var player := $Player
@onready var tile_map :TileMap = $TileMap
@onready var GUI = $GUI

#var tile_changed :Vector2i = Vector2i.ZERO:
#	set(value):
#		if value != tile_changed:
#			emit_signal("location_changed",value)
#		tile_changed = value
#	get:
#		return tile_changed

var player_map_pos :Vector2i
var selected_seed_type:int = CNST.MARAIS

var Tile_class :Tile = preload("res://Tile.gd").new()
var EndTurn :EndTurn = preload("res://EndTurnClass.gd").new()

func _ready():
	Autoload.turn_ended.connect(on_turn_ended)
	Autoload.update_seed_library("marais", +20)
	Autoload.update_seed_library("prairie", +20)
	Autoload.update_seed_library("foret", +20)
	player_moved.connect(player.on_player_moved)
	Tile_class.get_tilemap(tile_map)
	EndTurn.get_tilemap(tile_map)



func _unhandled_input(event):
	if Input.is_action_just_pressed("move_player") and !Input.is_key_label_pressed(KEY_CTRL):
		player.position = tile_map.map_to_local(mouse_map_pos)
		emit_signal("player_moved",player.global_position)
		
		
	if Input.is_action_just_pressed("right_click"):
		var terrain_under_player :int = Tile_class.check_type(player_map_pos)
		if Tile_class.count_surrounding_same_tiles(player_map_pos,terrain_under_player) == 6:
			var surround :Array[Vector2i]= tile_map.get_surrounding_cells(player_map_pos)
			surround.append(player_map_pos)
			match terrain_under_player:
				CNST.TERRE:
					harvest_seed(surround)
				CNST.PRAIRIE:
					build_megatile(surround,player_map_pos,CNST.PRAIRIE)
				CNST.FORET:
					build_megatile(surround,player_map_pos,CNST.FORET)
				CNST.MARAIS:
					build_megatile(surround,player_map_pos,CNST.MARAIS)
	
	if Input.is_action_just_pressed("planter_ramasser"):
			gather_or_plant_seed(mouse_map_pos)
	
	if Input.is_action_pressed("quit_game"):
		get_tree().quit()
	
	if Input.is_action_pressed("ui_accept"):
		Autoload.emit_signal("turn_ended")


func _process(delta):
	player_map_pos = tile_map.local_to_map(player.global_position)
	GUI.debug_label(mouse_map_pos)
	mouse_map_pos = tile_map.local_to_map(get_global_mouse_position())


func on_turn_ended()->void:
#	reset harvested tiles
	for harv_tile in harvested_tiles:
		tile_map.set_cell(CNST.LAYER_TERRAIN,harv_tile,CNST.BASE_TERRAIN,Vector2i(0,0))
		
	EndTurn.grow_planted_seeds(planted_tiles)
	harvested_tiles.clear()
	planted_tiles.clear()
	process_all_region_tiles()
	EndTurn.generate_seeds_from_megatiles(mega_tile_centers)


## détruit les tuiles du groupe et place une Megatuile
func build_megatile(surround, center_tile, type)->void:
# detruire
	for destroyable in surround:
		tile_map.erase_cell(CNST.LAYER_TERRAIN,destroyable)
# construire
	var megatuile:int
	var add_to_terrain_type_array :Callable = func(type_array :Array[Vector2i]):
		for tile in surround:
			type_array.append(tile)
	
	match type:
		CNST.MARAIS:
			megatuile = CNST.MEGA_MARAIS# ID du tileset megatuile Marais
			add_to_terrain_type_array.call(mega_marais)
		CNST.PRAIRIE:
			megatuile = CNST.MEGA_PRAIRIE# ID du tileset megatuile prairie
			add_to_terrain_type_array.call(mega_prairie)
		CNST.FORET:
			megatuile = CNST.MEGA_FORET# ID du tileset megatuile Forets
			add_to_terrain_type_array.call(mega_foret)
	tile_map.set_cell(CNST.LAYER_TERRAIN,center_tile,megatuile,Vector2i.ZERO)
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
# genere la graine 
	if harvestable == 7:
			Autoload.update_seed_library("marais", +1)
			harvested_tiles.append_array(new_harvested_tiles)
#			Change l'image de la tile harvested
			for tile in new_harvested_tiles:
				tile_map.set_cell(CNST.LAYER_TERRAIN,tile,CNST.BASE_TERRAIN,Vector2i(3,0))


func gather_or_plant_seed(click_pos:Vector2i)->void:
#	plant :
	var surround :Array[Vector2i] = tile_map.get_surrounding_cells(player_map_pos)
	surround.append(player_map_pos)
	if surround.has(click_pos) and not planted_tiles.has(click_pos):
		match Tile_class.check_type(click_pos):
			CNST.TERRE:
				if Autoload.seed_library.marais > 0:
					Autoload.update_seed_library("marais",-1)
					tile_map.set_cell(CNST.LAYER_OBJECTS,click_pos,CNST.OBJECTS,Vector2i.ZERO)
			CNST.MARAIS:
				if Autoload.seed_library.prairie > 0:
					Autoload.update_seed_library("prairie",-1)
					tile_map.set_cell(CNST.LAYER_OBJECTS,click_pos,CNST.OBJECTS,Vector2i(1,0))
			CNST.PRAIRIE:
				if Autoload.seed_library.foret > 0:
					Autoload.update_seed_library("foret",-1)
					tile_map.set_cell(CNST.LAYER_OBJECTS,click_pos,CNST.OBJECTS,Vector2i(2,0))
				
		planted_tiles.append(click_pos)


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
			var get_type :int = Tile_class.check_type(i)
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
		
		var processed_type :int = Tile_class.check_type(processed_cell)
		var surrounding_tiles :Array[Vector2i] = tile_map.get_surrounding_cells(processed_cell)
		var surrounding_types :Array = get_surrounding_types.call(surrounding_tiles)

		if processed_type >= 1: 
			match processed_type:
				CNST.PRAIRIE:
					if  surrounding_types[mega_type].has("mega_prairie"):
						print(processed_cell, " est voisin d'une megaprairie ")
				CNST.FORET:
					if  surrounding_types[mega_type].has("mega_foret"):
						print(processed_cell, " est voisin d'une megaforet")
				CNST.MARAIS:
					pass
				CNST.VILLE:
					pass
				CNST.POUBELLE:
					pass
				CNST.DESASTRE:
					pass
#		print("types around ",processed_cell," = ",surrounding_types)


#func generate_seeds_frome_megatiles()->void:
#	for seed in mega_tile_centers:
#		var mega_type :int = tile_map.get_cell_source_id(0,seed)
#		match mega_type :
#			CNST.MEGA_MARAIS :
#				tile_map.set_cell(CNST.LAYER_OBJECTS,seed,4,Vector2i(1,0))
#			CNST.MEGA_PRAIRIE:
#				tile_map.set_cell(CNST.LAYER_OBJECTS,seed,4,Vector2i(2,0))
#			CNST.MEGA_FORET:
#				tile_map.set_cell(CNST.LAYER_OBJECTS,seed,4,Vector2i(2,0))


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
