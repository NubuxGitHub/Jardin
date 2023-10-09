extends Node2D

var last_position: Vector2

@onready var anim_player = $AnimationPlayer







func _ready():
	anim_player.play("pl_teleport_01")
#	camera.global_position = self.global_position
#	last_position = self.global_position
	
	pass


func on_player_moved(new_position)->void:
#	var tw = get_tree().create_tween()
#	tw.tween_property(camera,"global_position",new_position,1.0).from(last_position)
#	last_position = new_position
	anim_player.play("pl_teleport_01")
	
#@export var speed :int = 10000
#var direction :Vector2
#
#
#func _unhandled_input(event):
#	if Input.is_action_pressed("ui_up"):
#		direction= cartesian_to_isometric(Vector2.UP)
#	elif Input.is_action_pressed("ui_down"):
#		direction = cartesian_to_isometric(Vector2.DOWN)
#	elif Input.is_action_pressed("ui_left"):
#		direction = cartesian_to_isometric(Vector2.LEFT)
#	elif Input.is_action_pressed("ui_right"):
#		direction = cartesian_to_isometric(Vector2.RIGHT)
#	else:
#		direction = Vector2.ZERO
#
#
#func _process(delta):
#	velocity = direction * speed * delta
#	Autoload.player_global_pos = self.position
#	move_and_slide()
#
#
#func cartesian_to_isometric(cartesian)->Vector2:
#	var isometric :Vector2
#	isometric.x = cartesian.x - cartesian.y
#	isometric.y = (cartesian.y + cartesian.x) /2
#	return isometric
