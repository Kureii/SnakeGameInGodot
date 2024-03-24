extends Sprite2D

var tile_map: TileMap
 
func _ready():
	tile_map = $"../../TileMap"
	


func _on_sneak_head_sprite_move_eat_to_position(pos_x, pos_y):
	print("event in eat")
	position = Vector2(pos_x, pos_y)
	global_position = tile_map.map_to_local(Vector2(pos_x, pos_y))
