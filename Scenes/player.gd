extends Node2D

var last_position: Vector2

@onready var anim_player = $AnimationPlayer







func _ready():
	anim_player.play("golem_appear")
#	camera.global_position = self.global_position
#	last_position = self.global_position
	


func on_player_moved(new_position)->void:
	anim_player.play("golem_appear")
	await anim_player.animation_finished
	anim_player.play("idle_01")
	

