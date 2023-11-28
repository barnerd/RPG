extends Area2D

@onready var actor: Actor = $".."

func _on_body_shape_entered(body_rid: RID, body: Node2D, _body_shape_index: int, _local_shape_index: int) -> void:

	if body is TileMap:
		_process_tilemap_collision(body, body_rid)


func _process_tilemap_collision(body: TileMap, body_rid: RID) -> void:
	var speed_multiplier
	
	var collided_tile_coords = body.get_coords_for_body_rid(body_rid)
	var tile_data: TileData = body.get_cell_tile_data(1, collided_tile_coords)
	
	if (tile_data):
		speed_multiplier = tile_data.get_custom_data("movement_speed_multiplier")
	else:
		speed_multiplier = 1
		
	actor.set_movement_speed_multipler(speed_multiplier)
