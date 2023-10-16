extends CanvasLayer


@onready var prairie_label = $PanelContainer/GridContainer/GrPrairieLabel
@onready var foret_label = $PanelContainer/GridContainer/GrForetLabel
@onready var marais_label = $PanelContainer/GridContainer/GrMaraisLabel
@onready var debug = $Debug

@onready var mega_mlabel = $MegattilesPCOnt/VBoxContainer/MegaMlabel
@onready var meg_foretlabel = $MegattilesPCOnt/VBoxContainer/MegForetlabel
@onready var meg_prairie_label = $MegattilesPCOnt/VBoxContainer/MegPrairieLabel


func _ready():
	Autoload.seed_number_changed.connect(on_seed_number_changed)
	Autoload.mega_tile_added.connect(on_mega_tile_added)

func on_seed_number_changed()->void:
	prairie_label.text = str(Autoload.seed_library.prairie)
	foret_label.text =   str(Autoload.seed_library.foret)
	marais_label.text =  str(Autoload.seed_library.marais)


func on_mega_tile_added()->void:
	mega_mlabel.text  = "mega marais: " + str(Autoload.mega_tile_tracking[0])
	meg_prairie_label.text = "mega prairie: " + str(Autoload.mega_tile_tracking[1])
	meg_foretlabel.text ="mega forets: " + str(Autoload.mega_tile_tracking[2])


func debug_label(data)->void:
	debug.text = str(data)
