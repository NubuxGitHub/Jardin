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
	TERRAIN_TSET = 0,
	OBJECTS_TSET     = 4,
	MEGA_MARAIS_TSET  = 10,
	MEGA_PRAIRIE_TSET = 11,
	MEGA_FORET_TSET   = 12,
	DEATH_TSET   = 100,
}


enum {
	LAYER_TERRAIN = 0,
	LAYER_OBJECTS = 1,
}

