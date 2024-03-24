extends Area2D

signal food_was_ate

func _ready():
	var snake = $"../"
	var snakeCallable = Callable(snake, "_on_eat_area_2d_child_entered_tree")
	self.connect("food_was_ate", snakeCallable)

func _on_kill_area_area_entered(area):
	if area.name == "SnakeHeadArea2D":
		get_tree().reload_current_scene()
		
func _on_eat_area_area_entered(area):
	print("eat!")
	food_was_ate.emit()
