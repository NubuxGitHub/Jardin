extends Node2D

#signal location_changed(Vector2i)

enum Terrains {
	EMPTY = -1,
	TERRE,
	PRAIRIE,
	FORET,
	MARAIS,
}
@export var region_size = 25

var harvested_tiles :Array[Vector2i] =[]
var planted_tiles   :Array[Vector2i] = []

var mega_prairie :Array[Vector2i] = []
var mega_foret   :Array[Vector2i] = []
var mega_marais  :Array[Vector2i] = []

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




func _ready():
	Autoload.turn_ended.connect(on_turn_ended)



func _unhandled_input(event):
	if Input.is_action_just_pressed("right_click"):
		player_map_pos = tile_map.local_to_map(Autoload.player_global_pos)
		var terrain_under_player = tile_map.get_cell_atlas_coords(0,player_map_pos).y
		if count_surrounding_same_tiles(player_map_pos,terrain_under_player) == 6:
			var surround = tile_map.get_surrounding_cells(player_map_pos)
			match terrain_under_player:
				Terrains.TERRE:
					harvest_seed(player_map_pos,surround)
				Terrains.PRAIRIE:
					build_megatile(surround,player_map_pos,Terrains.PRAIRIE)
				Terrains.FORET:
					build_megatile(surround,player_map_pos,Terrains.FORET)
				Terrains.MARAIS:
					build_megatile(surround,player_map_pos,Terrains.MARAIS)
	
	if Input.is_action_just_pressed("planter_ramasser"):
		if Autoload.seed_library.prairie >= 1:
			gather_or_plant_seed()
	
	if Input.is_action_pressed("quit_game"):
		get_tree().quit()
	
	if Input.is_action_pressed("ui_accept"):
		Autoload.emit_signal("turn_ended")


func _process(delta):
	player_map_pos = tile_map.local_to_map(Autoload.player_global_pos)
#	tile_changed = player_map_pos
	GUI.debug_label(player_map_pos)

#func _on_location_changed(value):
#	generate_tiles(value)


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



func count_surrounding_same_tiles(center_tile:Vector2i, type:int)->int:
#------
# Le type de la tuile est donné par sa coordonnée atlas Y .
# C'est à dire la ligne sur laquelle elle se trouve sur le tileset:
# vide = -1
# neutre = 0
# prairie = 1 etc...
#------
	var surround :Array = tile_map.get_surrounding_cells(center_tile)
	var counter :int = 0
	for cell in surround:
# on regarde le nombre de tuiles du meme type contigues
		if  tile_map.get_cell_atlas_coords(0,cell).y == type:
			counter += 1
#	print("nbre de terrains similaires = ",counter)
	return counter


## détruit les tuiles du groupe et place une Megatuile
func build_megatile(surround, center_tile,type)->void:
# detruire
	for destroyable in surround:
		tile_map.erase_cell(0,destroyable)
		
		

# construire
	var megatuile:int
	var add_to_terrain_type_array :Callable = func(type_array :Array[Vector2i]):
		for tile in surround:
			type_array.append(tile)
	match type:
		Terrains.PRAIRIE:
			megatuile = 1# ID du tileset megatuile prairie
			add_to_terrain_type_array.call(mega_prairie)
		Terrains.FORET:
			megatuile = 2# ID du tileset megatuile Forets
			add_to_terrain_type_array.call(mega_foret)
		Terrains.MARAIS:
			megatuile = 3# ID du tileset megatuile Marais
			add_to_terrain_type_array.call(mega_marais)
	
	tile_map.set_cell(0,center_tile,megatuile,Vector2i.ZERO)


func harvest_seed(center_cell,surround)->void:
	var harvestable :int = 0
	surround.append(center_cell)
	var new_harvested_tiles :Array[Vector2i]=[]
	for each in surround:
		if harvested_tiles.has(each):
			break
		else: 
			new_harvested_tiles.append(each)
			harvestable+=1
	print("-----","\nharvestables = ",harvestable,"\n new harvested tiles = ",new_harvested_tiles, "\n harvested _tiles = ", harvested_tiles)
# genere la graine 
	if harvestable == 7:
			Autoload.seed_library.prairie += 1
			harvested_tiles.append_array(new_harvested_tiles)
			print("graine de Prairie = ",Autoload.seed_library.prairie)
			Autoload.emit_signal("seed_number_changed")
			change_tile(new_harvested_tiles)


func change_tile(tile_array :Array[Vector2i] = [])->void:
	for tile in tile_array:
		tile_map.set_cell(0,tile,0,Vector2i(3,0))


func gather_or_plant_seed()->void:
#	plant :
	var ground_type :int = tile_map.get_cell_atlas_coords(0,player_map_pos).y
	if ground_type == Terrains.TERRE and not planted_tiles.has(player_map_pos):
		print ("graine plantée")
		planted_tiles.append(player_map_pos)
		Autoload.seed_library.prairie -=1
		Autoload.emit_signal("seed_number_changed")
		tile_map.set_cell(1,player_map_pos,4,Vector2i.ZERO)
# Gather:
#	if tile_map.get_cell_atlas_coords(1,player_map_pos) == Vector2i.ZERO:
#		tile_map.erase_cell(1,player_map_pos)
#		Autoload.seed_library.prairie += 1
#		Autoload.emit_signal("seed_number_changed")
#		print("graine glanée")
#		if planted_tiles.has(player_map_pos):
#			planted_tiles.erase(player_map_pos)



		
#func get_cluster()->Array[Vector2i]:
#	var cluster: Array[Vector2i] = []
#	cluster.append(tile_map.get_surrounding_cells(player_map_pos))
#	cluster.append(player_map_pos)
#	return cluster
