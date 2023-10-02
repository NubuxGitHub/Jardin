extends CanvasLayer


@onready var prairie_label = $PanelContainer/VBoxContainer/GrPrairieLabel
@onready var foret_label = $PanelContainer/VBoxContainer/GrForetLabel
@onready var marais_label = $PanelContainer/VBoxContainer/GrMaraisLabel
@onready var debug = $Debug


func _ready():
	Autoload.seed_number_changed.connect(on_seed_number_changed)


func on_seed_number_changed()->void:
	prairie_label.text = "Graine de prairie = " + str(Autoload.seed_library.prairie)
	foret_label.text =   "Graine de foret = " + str(Autoload.seed_library.foret)
	marais_label.text =  "Graine de marais = " + str(Autoload.seed_library.marais)


func debug_label(data)->void:
	debug.text = str(data)
