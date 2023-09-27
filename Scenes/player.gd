extends CharacterBody2D

@export var speed :int = 10000
var direction :Vector2


func _unhandled_input(event):
	if Input.is_action_pressed("ui_up"):
		direction= cartesian_to_isometric(Vector2.UP)
	elif Input.is_action_pressed("ui_down"):
		direction = cartesian_to_isometric(Vector2.DOWN)
	elif Input.is_action_pressed("ui_left"):
		direction = cartesian_to_isometric(Vector2.LEFT)
	elif Input.is_action_pressed("ui_right"):
		direction = cartesian_to_isometric(Vector2.RIGHT)
	else:
		direction = Vector2.ZERO


func _process(delta):
	velocity = direction * speed * delta
	Autoload.player_global_pos = self.position
	move_and_slide()


func cartesian_to_isometric(cartesian)->Vector2:
	var isometric :Vector2
	isometric.x = cartesian.x - cartesian.y
	isometric.y = (cartesian.y + cartesian.x) /2
	return isometric
