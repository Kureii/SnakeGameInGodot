extends Sprite2D

signal move_eat_to_position(pos_x, pos_y)

@export var move_delay = 1.0
@export var body_segment_texture_horizontal_down = preload("res://assets/snake/Snake-body-horizontal_down.png")
@export var body_segment_texture_horizontal_up = preload("res://assets/snake/Snake-body-horizontal_up.png")
@export var body_segment_texture_vertical_left = preload("res://assets/snake/Snake-body-vertical_left.png")
@export var body_segment_texture_vertical_right = preload("res://assets/snake/Snake-body-vertical_right.png")
@export var body_segment_texture_turn_down_right = preload("res://assets/snake/Snake-body-turn-down-right.png")
@export var body_segment_texture_turn_up_right = preload("res://assets/snake/Snake-body-turn-up-right.png")
@export var body_segment_texture_turn_down_left = preload("res://assets/snake/Snake-body-turn-down-left.png")
@export var body_segment_texture_turn_up_left = preload("res://assets/snake/Snake-body-turn-up-left.png")
@export var body_segment_texture_end_left = preload("res://assets/snake/Snake-body-end-left.png")
@export var body_segment_texture_end_right = preload("res://assets/snake/Snake-body-end-right.png")
@export var body_segment_texture_end_up = preload("res://assets/snake/Snake-body-end-up.png")
@export var body_segment_texture_end_down = preload("res://assets/snake/Snake-body-end-down.png")
@export var body_length = 5

@onready var tile_map = $"../../TileMap"
@onready var score_label = $"../../ScoreLabel"
@onready var new_position = get_next_position()

var direction = 0
var requested_direction = null
var positions_history = []
var body_segments = []
var body_down = true
var body_left = true
var body_up_down_counter = 0
var body_left_right_counter = 0
var random = RandomNumberGenerator.new()
var score = 0

func _ready():
	change_score()
	
	var timer = Timer.new()
	timer.wait_time = move_delay
	timer.one_shot = false
	timer.timeout.connect(_on_Timer_timeout)
	add_child(timer)
	timer.start()
	
	var previous_position = tile_map.local_to_map(global_position)
	
	for i in range(body_length):
		var current_position = get_tail_position(180, previous_position)
		previous_position = current_position
		var segment = Sprite2D.new()
		
		set_horizontal_body_texture(segment)
		
		add_child(segment)
		segment.global_position = tile_map.map_to_local(current_position)
		body_segments.append(segment)
		
		positions_history.append(current_position)
	body_segments[-1].texture = body_segment_texture_end_right
	positions_history.pop_back()
	
	var eat = $"../../Food/Eat"
	var eatCallable = Callable(eat, "_on_sneak_head_sprite_move_eat_to_position")
	self.connect("move_eat_to_position", eatCallable)
	generate_eat_position()

func generate_eat_position():
	var head_position = tile_map.local_to_map(global_position)
	var eat_x_position = random.randi_range(3, 30)
	
	while eat_x_position == head_position.x or eat_x_position in body_segments:
		eat_x_position = random.randi_range(3, 30)
		
	var eat_y_position = random.randi_range(3, 30)
	
	while eat_y_position == head_position.x or eat_y_position in body_segments:
		eat_y_position = random.randi_range(3, 30)
		
	print("position generated")
	move_eat_to_position.emit(eat_x_position, eat_y_position)
		

func set_horizontal_body_texture(segment):
	if body_down:
			segment.texture = body_segment_texture_horizontal_down
			body_down = !body_down
	else:
		segment.texture = body_segment_texture_horizontal_up
		body_down = !body_down
	body_up_down_counter += 1
		
func set_vertical_body_texture(segment):
	if body_left:
			segment.texture = body_segment_texture_vertical_left
			body_left = !body_left
	else:
		segment.texture = body_segment_texture_vertical_right
		body_left = !body_left
	body_left_right_counter += 1

func _input(event):
	if Input.is_action_pressed("move_up") and direction != 270:
		requested_direction = {"rot": PI * 1.5, "dir": 90}
	elif Input.is_action_pressed("move_down") and direction != 90:
		requested_direction = {"rot": PI / 2, "dir": 270}
	elif Input.is_action_pressed("move_left") and direction != 0:
		requested_direction = {"rot": PI, "dir": 180}
	elif Input.is_action_pressed("move_right") and direction != 180:
		requested_direction = {"rot": 0, "dir": 0}

func get_next_position():
	var new_pos = tile_map.local_to_map(global_position)
	match direction:
		0: new_pos.x += 1
		90: new_pos.y -= 1
		180: new_pos.x -= 1
		270: new_pos.y += 1
	return tile_map.map_to_local(new_pos)

func get_tail_position(dir, pos):
	match dir:
		0: pos.x += 1
		90: pos.y -= 1
		180: pos.x -= 1
		270: pos.y += 1
	return pos

func _on_Timer_timeout():
	if requested_direction != null:
		direction = requested_direction["dir"]
		global_rotation = requested_direction["rot"]
		requested_direction = null
	new_position = get_next_position()
	positions_history.insert(0, tile_map.local_to_map(global_position))
	while positions_history.size() > body_length:
		positions_history.pop_back()

	global_position = new_position
	update_body_positions()
	
func update_body_positions():
	for i in range(body_segments.size()):
		if i < positions_history.size():
			body_segments[i].global_position = tile_map.map_to_local(positions_history[i])
			body_segments[i].global_rotation = 0
			update_body_texture(i)
			
	reset_body_texture_counter()
	if self_bite():
		end_game()
	
func reset_body_texture_counter():
	if !body_up_down_counter % 2:
		body_down = !body_down
	body_up_down_counter = 0
	
	if !body_left_right_counter % 2:
		body_left = !body_left
	body_left_right_counter = 0
	
func update_body_texture(i):
	if i == 0:
		var head_position = tile_map.local_to_map(global_position)
		update_body_texture_behind_head(head_position, i)
	elif i < positions_history.size() - 1:
		update_body_texture_behind_head(positions_history[i-1], i)
	else:
		update_bodyy_texture_end(i)
		body_segments[i].show()
			
func update_bodyy_texture_end(i):
	if positions_history[i-1].x < positions_history[i].x:
		body_segments[i].texture = body_segment_texture_end_left
	elif positions_history[i-1].x > positions_history[i].x:
		body_segments[i].texture = body_segment_texture_end_right
	elif positions_history[i-1].y < positions_history[i].y:
		body_segments[i].texture = body_segment_texture_end_up
	elif positions_history[i-1].y > positions_history[i].y:
		body_segments[i].texture = body_segment_texture_end_down

func update_body_texture_behind_head(before_position, i):
	if before_position.y == positions_history[i].y and \
		positions_history[i].y == positions_history[i+1].y:
			
		set_horizontal_body_texture(body_segments[i])
	elif before_position.x == positions_history[i].x and \
		positions_history[i].x == positions_history[i+1].x:
			
		set_vertical_body_texture(body_segments[i])
	elif before_position.x <= positions_history[i].x and before_position.y >= positions_history[i].y and \
		positions_history[i].x >= positions_history[i + 1].x and positions_history[i].y <= positions_history[i + 1].y:
		body_segments[i].texture = body_segment_texture_turn_down_left
	elif before_position.x >= positions_history[i].x and before_position.y <= positions_history[i].y and \
		positions_history[i].x <= positions_history[i + 1].x and positions_history[i].y >= positions_history[i + 1].y:
		body_segments[i].texture = body_segment_texture_turn_up_right
	elif before_position.x <= positions_history[i].x and before_position.y <= positions_history[i].y and \
		positions_history[i].x >= positions_history[i + 1].x and positions_history[i].y >= positions_history[i + 1].y:
		body_segments[i].texture = body_segment_texture_turn_up_left
	elif before_position.x >= positions_history[i].x and before_position.y >= positions_history[i].y and \
		positions_history[i].x <= positions_history[i + 1].x and positions_history[i].y <= positions_history[i + 1].y:
		body_segments[i].texture = body_segment_texture_turn_down_right

func self_bite():
	var head_position = tile_map.local_to_map(global_position)
	return head_position in positions_history
	
func end_game():
	print("end game with scoore: " + str(score))
	get_tree().reload_current_scene()

func _on_eat_area_2d_child_entered_tree():
	print("_on_eat_area_2d_child_entered_tree")
	generate_eat_position()
	add_body_segment()
	
func add_body_segment():
	var angle = 0
	if positions_history[-1].x < positions_history[-2].x:
		angle = 180
	elif positions_history[-1].x > positions_history[-2].x:
		angle = 0
	elif positions_history[-1].y < positions_history[-2].y:
		angle = 270
	elif positions_history[-1].y > positions_history[-2].y:
		angle = 90
	var current_position = get_tail_position(angle, positions_history[-1])
	var last_index = positions_history.size() - 1
	var segment = Sprite2D.new()
		
	add_child(segment)
	segment.global_position = tile_map.map_to_local(current_position)
	
	body_segments.append(segment)
	
	positions_history.append(current_position)
	segment.hide()
	body_length +=1
	score += 1
	change_score()
	
func change_score():
	score_label.text = "Score: " + str(score)
