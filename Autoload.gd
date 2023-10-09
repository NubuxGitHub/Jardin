extends Node

signal turn_ended
signal seed_number_changed

#




var seed_library :Dictionary = {
		"marais" : 0,
		"prairie"   : 0,
		"foret"  : 0,
}


func update_seed_library(type :String, amount : int = 0)->void :
	match type:
		"prairie":
			seed_library.prairie += amount 
		"foret":
			seed_library.foret += amount 
		"marais":
			seed_library.marais += amount 
		
	emit_signal("seed_number_changed")
