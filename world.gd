extends Node2D

signal location_changed(Vector2i)
@onready var player := $Player
@onready var tile_map := $TileMap

var tile_changed :Vector2i =Vector2i.ZERO:
	set(value):
		if value != tile_changed:
			emit_signal("location_changed",value)
		tile_changed = value
	get:
		return tile_changed

#var tile_library : Dictionary ={
#	"prairie" : [],
#	"terre": [],
#	"marais": [],
#	"desert" : []
#}


var mouse_map_pos :Vector2i
var mouse_global_pos : Vector2i

func _ready():
	for y in 20:
		for x in 20:
			tile_map.set_cell(0,Vector2i(x,y),1,Vector2i.ZERO)


func _unhandled_input(event):
	if Input.is_action_just_pressed("left_click"):
		mouse_global_pos = get_global_mouse_position()
		mouse_map_pos = tile_map.local_to_map(mouse_global_pos)
		var surounding_tiles = tile_map.get_surrounding_cells(mouse_map_pos)
		print(surounding_tiles)
#		generate_tiles(mouse_map_pos)
	if Input.is_action_pressed("quit_game"):
		get_tree().quit()


func _process(delta):
	var player_map_pos = tile_map.local_to_map(Autoload.player_global_pos)
	tile_changed = player_map_pos


func generate_tiles(tile_pos)->void:
	var chosen_tile :Vector2i = Vector2i(randi_range(0,2),randi_range(1,2))
	tile_map.set_cell(0,tile_pos,1,chosen_tile)
	


func _on_location_changed(value):
	generate_tiles(value)
