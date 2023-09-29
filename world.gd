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

#var tile_changed :Vector2i = Vector2i.ZERO:
#	set(value):
#		if value != tile_changed:
#			emit_signal("location_changed",value)
#		tile_changed = value
#	get:
#		return tile_changed

var mouse_map_pos :Vector2i
var mouse_global_pos : Vector2i




func _ready():
#	for y in region_size:
#		for x in region_size:
#			tile_map.set_cell(0,Vector2i(x,y),1,Vector2i.ZERO)
	pass


func _unhandled_input(event):
	if Input.is_action_just_pressed("left_click"):
		mouse_global_pos = get_global_mouse_position()
		mouse_map_pos = tile_map.local_to_map(mouse_global_pos)
		var surounding_tiles = tile_map.get_surrounding_cells(mouse_map_pos)
		print(surounding_tiles)
#		generate_tiles(mouse_map_pos)
	if Input.is_action_pressed("quit_game"):
		get_tree().quit()
	if Input.is_action_pressed("ui_accept"):
		resolve_end_turn()


func _process(delta):
	var player_map_pos = tile_map.local_to_map(Autoload.player_global_pos)
#	tile_changed = player_map_pos


#func generate_tiles(tile_pos)->void:
#	var chosen_tile :Vector2i = Vector2i(randi_range(0,2),randi_range(1,3))
#	tile_map.set_cell(0,tile_pos,0,chosen_tile)


#func _on_location_changed(value):
#	generate_tiles(value)


func resolve_end_turn()->void:
	for y in region_size:
		for x in region_size:
			var cell_type :int = tile_map.get_cell_atlas_coords(0,Vector2i(x,y)).y
			check_surrounding_tiles(Vector2i(x,y),cell_type)


func check_surrounding_tiles(tile:Vector2i, type:int):
	var surround :Array = tile_map.get_surrounding_cells(tile)
	var counter :int = 0
# Le type de la tuile est donné par sa coordonnée atlas Y .
# C'est à dire la ligne sur laquelle elle se trouve sur le tileset:
# vide = -1
# neutre = 0
# prairie = 1 etc...
	for cell in surround:
		if type >= 1 and tile_map.get_cell_atlas_coords(0,cell).y == type:
			counter += 1
			if counter == 6 :
				for destroyable in surround:
					tile_map.erase_cell(0,destroyable)
				tile_map.erase_cell(0,tile)
				build_megatile(tile,type)
#				print (tile," = MegaTuile de type ",type); return



func build_megatile(tile,type)->void:
	var megatuile:int
	match type:
		Terrains.PRAIRIE:
			megatuile = 1# ID du tileset megatuile prairie
		Terrains.FORET:
			megatuile = 2# ID du tileset megatuile Forets
		Terrains.MARAIS:
			megatuile = 3# ID du tileset megatuile Marais
			
	tile_map.set_cell(0,tile,megatuile,Vector2i.ZERO)

