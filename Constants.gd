extends Node

class_name CNST

#  ci_dessous les numeros = atlas_coord.y sur le tilset terrains et 100 
# et plus pour les coordonnées du tileset tuiles_mort
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

#ci_dessous les numeros = source_ID des tileset:
enum {
	BASE_TERRAIN = 0,
	MEGA_MARAIS  = 1,
	MEGA_PRAIRIE = 2,
	MEGA_FORET   = 3,
	OBJECTS      = 4,
}


enum {
	LAYER_TERRAIN = 0,
	LAYER_OBJECTS = 1,
}

