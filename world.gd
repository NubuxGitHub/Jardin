extends Node2D

#signal location_changed(Vector2i)

enum Terrains {
	EMPTY = -1,
	STERILE,
	PRAIRIE,
	FORET,
	MARAIS,
}
@export var region_size = 25
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
var player_global_pos : Vector2i




func _ready():
#	for y in region_size:
#		for x in region_size:
#			tile_map.set_cell(0,Vector2i(x,y),1,Vector2i.ZERO)
	pass


func _unhandled_input(event):
	if Input.is_action_just_pressed("right_click"):
		player_global_pos = player.position
		player_map_pos = tile_map.local_to_map(player_global_pos)
		var terrain_under_player = tile_map.get_cell_atlas_coords(0,player_map_pos).y
		if count_surrounding_same_tiles(player_map_pos,terrain_under_player) == 6:
			var surround = tile_map.get_surrounding_cells(player_map_pos)
			match terrain_under_player:
				Terrains.STERILE:
					Autoload.seed_library.prairie += 1
					print("graine de Prairie = ",Autoload.seed_library.prairie)
					Autoload.emit_signal("seed_number_changed")
				Terrains.PRAIRIE:
					build_megatile(surround,player_map_pos,Terrains.PRAIRIE)
				Terrains.FORET:
					build_megatile(surround,player_map_pos,Terrains.FORET)
				Terrains.MARAIS:
					build_megatile(surround,player_map_pos,Terrains.MARAIS)


	if Input.is_action_pressed("quit_game"):
		get_tree().quit()
#	if Input.is_action_pressed("ui_accept"):
#		resolve_end_turn()


func _process(delta):
	var player_map_pos = tile_map.local_to_map(Autoload.player_global_pos)
#	tile_changed = player_map_pos


#func _on_location_changed(value):
#	generate_tiles(value)


func resolve_end_turn()->void:
#	for y in region_size:
#		for x in region_size:
#			var cell_type :int = tile_map.get_cell_atlas_coords(0,Vector2i(x,y)).y
#			count_surrounding_same_tiles(Vector2i(x,y),cell_type)
	pass


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
	print("nbre de terrains similaires = ",counter)
	return counter


## détruit les tuiles du groupe et place une Megatuile
func build_megatile(surround, center_tile,type)->void:
# detruire
	for destroyable in surround:
		tile_map.erase_cell(0,destroyable)
	tile_map.erase_cell(0,center_tile)
# construire
	var megatuile:int
	match type:
		Terrains.PRAIRIE:
			megatuile = 1# ID du tileset megatuile prairie
		Terrains.FORET:
			megatuile = 2# ID du tileset megatuile Forets
		Terrains.MARAIS:
			megatuile = 3# ID du tileset megatuile Marais
	tile_map.set_cell(0,center_tile,megatuile,Vector2i.ZERO)

