extends Area2D

func _ready():
	var snake = $"../../../Snake/SneakHeadSprite/SnakeHeadArea2D"
	var snakeCallable = Callable(snake, "_on_eat_area_area_entered")
	self.connect("area_entered", snakeCallable)


