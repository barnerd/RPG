class_name Actor extends CharacterBody2D

@export var speed = 100 # How fast the player will move (pixels/sec).
@export var acceleration = 100 # How fast the player will speed up (pixels/sec).
@export var deceleration = 100 # How fast the player will slow down (pixels/sec).

var input_direction:Vector2
@onready var animationPlayer = $AnimationPlayer
var speed_multiplier: float = 1

func _process(delta):
	if (input_direction.length_squared() > 0):
		velocity = velocity.move_toward(input_direction.normalized() * speed * speed_multiplier, acceleration * speed_multiplier * delta)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, deceleration * speed_multiplier * delta)	

	if (velocity.x != 0):
		flip_sprite(velocity.x > 0)

func _physics_process(_delta):
	move_and_slide()

func update_input_direction(_direction:Vector2):
	input_direction = _direction

func flip_sprite(_right = true):
	$GFX.scale.x = -1 if _right else 1

func attack():
	animationPlayer.play("swing_attack")

func set_movement_speed_multipler(_multiplier: float):
	speed_multiplier = _multiplier if(_multiplier != null) else 1.0
