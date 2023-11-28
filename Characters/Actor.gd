class_name Actor extends CharacterBody2D

@export var speed = 100 # How fast the player will move (pixels/sec).
@export var acceleration = 100 # How fast the player will speed up (pixels/sec).
@export var deceleration = 100 # How fast the player will slow down (pixels/sec).
@export var is_player: bool

var controls_active: bool = true

var input_direction:Vector2
@onready var animationPlayer = $AnimationPlayer
var speed_multiplier: float = 1

@export var enemyData: BattleActorData

signal player_collided_with_enemy(_enemy: BattleActorData)


func _process(delta) -> void:
	if (input_direction.length_squared() > 0):
		velocity = velocity.move_toward(input_direction.normalized() * speed * speed_multiplier, acceleration * speed_multiplier * delta)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, deceleration * speed_multiplier * delta)	

	if (velocity.x != 0):
		flip_sprite(velocity.x > 0)


func _physics_process(_delta) -> void:
	move_and_slide()
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		if collision.get_collider() is Actor && is_player && controls_active:
			controls_active = false
			$Camera2D.enabled = false
			var enemy = collision.get_collider() as Actor
			player_collided_with_enemy.emit(enemy.enemyData) # send encounter instead of actor
			enemy.queue_free()


func update_input_direction(_direction:Vector2) -> void:
	if controls_active:
		input_direction = _direction


func flip_sprite(_right = true) -> void:
	$GFX.scale.x = -1 if _right else 1


func attack() -> void:
	animationPlayer.play("swing_attack")


func set_movement_speed_multipler(_multiplier: float) -> void:
	speed_multiplier = _multiplier if(_multiplier != null) else 1.0


func on_battle_over() -> void:
	controls_active = true
	$Camera2D.enabled = true
