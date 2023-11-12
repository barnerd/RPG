extends Node

var input_direction = Vector2.ZERO # The player's movement vector.

func _input(_event):
	input_direction = Vector2.ZERO # The player's movement vector.

	input_direction.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	input_direction.y = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	
	$"..".update_input_direction(input_direction)
	
	if (Input.is_action_pressed("attack")):
		$"..".attack()
