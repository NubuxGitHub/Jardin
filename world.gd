extends Node2D




signal player_moved


var harvested_tiles :Array[Vector2i] = []
var planted_tiles   :Array[Vector2i] = []

var mega_prairie :Array[Vector2i] = []
var mega_foret   :Array[Vector2i] = []
var mega_marais  :Array[Vector2i] = []
var mega_tile_centers :Array[Vector2i]=[]
var mouse_map_pos: Vector2i


var player_map_pos :Vector2i
var selected_seed_type:int = CNST.MARAIS

var Tile_class :Tile = preload("res://Tile.gd").new()
var EndTurn :EndTurn = preload("res://EndTurnClass.gd").new()
var rnd_sprite = randi_range(0,2)
@onready var player := %Player
@onready var tile_map :TileMap = %TileMap
@onready var GUI = $GUI


#----------------------------------------------------
func _ready():
	Autoload.turn_ended.connect(on_turn_ended)
#	Autoload.update_seed_library("marais", +20)
#	Autoload.update_seed_library("prairie", +20)
#	Autoload.update_seed_library("foret", +20)
	player_moved.connect(player.on_player_moved)
	Tile_class.get_tilemap(tile_map)
	EndTurn.get_tilemap(tile_map)


func _unhandled_input(event):
	if Input.is_action_just_pressed("move_player") and !Input.is_key_label_pressed(KEY_CTRL):
		player.position = tile_map.map_to_local(mouse_map_pos)
		emit_signal("player_moved",player.global_position)
		Tile_class.gather_seed(mouse_map_pos)
		
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
			plant_seed(mouse_map_pos)
		
	if Input.is_action_pressed("quit_game"):
		get_tree().quit()
		
	if Input.is_action_just_pressed("end_turn"):
		Autoload.emit_signal("turn_ended")


func _process(delta):
	player_map_pos = tile_map.local_to_map(player.global_position)
	GUI.debug_label(mouse_map_pos)
	mouse_map_pos = tile_map.local_to_map(get_global_mouse_position())


func on_turn_ended()->void:
#	reset harvested tiles
	for harv_tile in harvested_tiles:
#		tile_map.set_cell(CNST.LAYER_TERRAIN,harv_tile,CNST.TERRAIN_TSET,Vector2i(0,0))
		Tile_class.set_terrain_cell(harv_tile,CNST.TERRE)
	harvested_tiles.clear()
	process_all_region_tiles()
	EndTurn.grow_planted_seeds(planted_tiles)
	EndTurn.generate_seeds_from_megatiles()
	planted_tiles.clear()


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
			megatuile = CNST.MEGA_MARAIS_TSET# ID du tileset megatuile Marais
			add_to_terrain_type_array.call(mega_marais)
			Autoload.mega_tile_tracking[0] +=1
			Autoload.emit_signal("mega_tile_added")
		CNST.PRAIRIE:
			megatuile = CNST.MEGA_PRAIRIE_TSET# ID du tileset megatuile prairie
			add_to_terrain_type_array.call(mega_prairie)
			Autoload.mega_tile_tracking[1]+=1
			Autoload.emit_signal("mega_tile_added")
		CNST.FORET:
			megatuile = CNST.MEGA_FORET_TSET# ID du tileset megatuile Forets
			add_to_terrain_type_array.call(mega_foret)
			Autoload.mega_tile_tracking[2] +=1
			Autoload.emit_signal("mega_tile_added")
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
				tile_map.set_cell(CNST.LAYER_TERRAIN,tile,CNST.TERRAIN_TSET,Vector2i(3,0))


func plant_seed(click_pos:Vector2i)->void:
	var surround :Array[Vector2i] = tile_map.get_surrounding_cells(player_map_pos)
	surround.append(player_map_pos)
	if surround.has(click_pos) and not planted_tiles.has(click_pos):
		match Tile_class.check_type(click_pos):
			CNST.TERRE:
				if Autoload.seed_library.marais > 0:
					Autoload.update_seed_library("marais",-1)
					tile_map.set_cell(CNST.LAYER_OBJECTS,click_pos,CNST.OBJECTS_TSET,Vector2i.ZERO)
			CNST.MARAIS:
				if Autoload.seed_library.prairie > 0:
					Autoload.update_seed_library("prairie",-1)
					tile_map.set_cell(CNST.LAYER_OBJECTS,click_pos,CNST.OBJECTS_TSET,Vector2i(1,0))
			CNST.PRAIRIE:
				if Autoload.seed_library.foret > 0:
					Autoload.update_seed_library("foret",-1)
					tile_map.set_cell(CNST.LAYER_OBJECTS,click_pos,CNST.OBJECTS_TSET,Vector2i(2,0))
				
		planted_tiles.append(click_pos)


func process_all_region_tiles()->void:
	var all_terrain_tiles :Array[Vector2i] = tile_map.get_used_cells(0)
	for processed_cell in all_terrain_tiles:
		var type :int = 0
		var mega_type: int = 1
	
		var processed_type :int = Tile_class.check_type(processed_cell)
		var surrounding_tiles :Array[Vector2i] = tile_map.get_surrounding_cells(processed_cell)
		var surrounding_types :Array = get_surrounding_types(surrounding_tiles)
	
		if processed_type >= CNST.MARAIS: 
			match processed_type:
				CNST.MARAIS:
					var  death_tiles_count:Vector2i = EndTurn.count_life_and_death(surrounding_types[type],"death")
					if death_tiles_count.y >=3 and not surrounding_types[mega_type].has("mega_marais"):
						tile_map.set_cell(CNST.LAYER_TERRAIN,processed_cell,CNST.TERRAIN_TSET,Vector2i(rnd_sprite,CNST.TERRE))
				CNST.PRAIRIE:
					var  death_tiles_count:Vector2i = EndTurn.count_life_and_death(surrounding_types[type],"death")
					if death_tiles_count.y >=3 and not surrounding_types[mega_type].has("mega_prairie"):
						Tile_class.set_terrain_cell(processed_cell, CNST.MARAIS)
#						tile_map.set_cell(CNST.LAYER_TERRAIN,processed_cell,CNST.TERRAIN_TSET,Vector2i(rnd_sprite,CNST.MARAIS))
				CNST.FORET:
					var  death_tiles_count:Vector2i = EndTurn.count_life_and_death(surrounding_types[type],"death")
					if death_tiles_count.y >=3 and not surrounding_types[mega_type].has("mega_foret"):
#						tile_map.set_cell(CNST.LAYER_TERRAIN,processed_cell,CNST.TERRAIN_TSET,Vector2i(rnd_sprite,CNST.PRAIRIE))
						Tile_class.set_terrain_cell(processed_cell, CNST.PRAIRIE)
				CNST.VILLE:
					var  life_tiles_count:Vector2i = EndTurn.count_life_and_death(surrounding_types[type],"life")
					if life_tiles_count.y >= 3:
#						tile_map.set_cell(CNST.LAYER_TERRAIN,processed_cell,CNST.TERRAIN_TSET,Vector2i(rnd_sprite,CNST.TERRE))
						Tile_class.set_terrain_cell(processed_cell, CNST.TERRE)
				CNST.POUBELLE:
					var  life_tiles_count:Vector2i = EndTurn.count_life_and_death(surrounding_types[type],"life")
					if life_tiles_count.y >= 3 and life_tiles_count.x >= 2:
#						tile_map.set_cell(CNST.LAYER_TERRAIN,processed_cell,CNST.TERRAIN_TSET,Vector2i(rnd_sprite,CNST.TERRE))
						Tile_class.set_terrain_cell(processed_cell, CNST.TERRE)
				CNST.DESASTRE:
					var  life_tiles_count:Vector2i = EndTurn.count_life_and_death(surrounding_types[type],"life")
					if life_tiles_count.y >= 3 and life_tiles_count.x >= 3:
#							tile_map.set_cell(CNST.LAYER_TERRAIN,processed_cell,CNST.TERRAIN_TSET,Vector2i(rnd_sprite,CNST.TERRE))
						Tile_class.set_terrain_cell(processed_cell, CNST.TERRE)
#		print("types around ",processed_cell," = ",surrounding_types)


func get_surrounding_types (surround)->Array :
		var type :Array[int]=[]
		var mega_type_array :Array[String]=[""]
		var combined_array :Array =[]
		for i in surround:
		# build type array:
			var get_type :int = Tile_class.check_type(i)
			if get_type >= CNST.MARAIS:
				type.append(get_type)
		# build  mega-type array:
			if  mega_prairie.has(i): mega_type_array.append("mega_prairie")
			if  mega_foret.has(i):   mega_type_array.append("mega_foret")
			if  mega_marais.has(i):  mega_type_array.append("mega_marais")
		#return combined arrays:
		combined_array.append(type)
		combined_array.append(mega_type_array)
		return combined_array


#func gather_seed(pos:Vector2i):
#	pass
## retourne un Vector2i dont
## x = le nombre de types hostiles differents,
## y = total des tuiles hostiles
#func count_life_and_death( types:Array[int], alignement:String)->Vector2i:
#	var total: Array = []
#	var x_variety_count:int = 0
#	match alignement:
#		"life":
#			for type in types:
#				if  not total.has(type):
#					x_variety_count += 1
#				elif type < CNST.VILLE:
#					total.append(type)
#		"death":
#			for type in types:
#				if  not total.has(type):
#					x_variety_count += 1
#				elif type >= CNST.VILLE:
#					total.append(type)
#	var y_total :int = total.size()
#	return Vector2i(x_variety_count,y_total)
			
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
