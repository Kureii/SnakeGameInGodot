extends Area2D

signal food_was_ate
signal end_game_collision

func _ready():
	var snake = $"../"
	var snake_callable_eat = Callable(snake, "_on_eat_area_2d_child_entered_tree")
	var snake_callable_death = Callable(snake, "_on_end_game")
	self.connect("food_was_ate", snake_callable_eat)
	self.connect("end_game_collision", snake_callable_death)

func _on_kill_area_area_entered(area):
	if area.name == "SnakeHeadArea2D":
		end_game_collision.emit()
		
func _on_eat_area_area_entered(area):
	food_was_ate.emit()
