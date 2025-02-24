extends Node2D
@export var parent_node: Node2D
@export var child_node: PackedScene
@export var distance: float = 100.0  # Distance between nodes
var levels = []

func get_valid_moves():
	return [parent_node] if parent_node else []

func _generate_map():
	var parent = child_node.instantiate()
	add_child(parent)
	parent.position = $AnimatedSprite2D.position
	levels.append([parent])
	var num_levels = randi_range(2, 3)  # Randomly pick between 3 and 4 levels
	print("num:" + str(num_levels))
	
	for level in range(num_levels):
		var num_nodes = randi_range(2, 3)  # Randomly pick between 3 and 4 nodes per level
		var current_level_nodes = []
		print(num_nodes)
		
		for i in range(num_nodes):
			var new_node = child_node.instantiate()
			new_node.position = Vector2(randi_range(1,4)*200, (level+2.25) * distance)  # Set position with distance spacing
			add_child(new_node)
			current_level_nodes.append(new_node)
		
		levels.append(current_level_nodes)
	var boss = child_node.instantiate()
	boss.position = Vector2(541, 5.25*distance)
	boss.modulate = Color(1, 0, 0)
	add_child(boss)
	levels.append(boss)
		
		# Assign parent-child relationships between levels
func _connect_nodes():
	for level in levels[len(levels)-2]:
		_draw_line(level.position, levels[len(levels)-1].position)
	for level in levels[1]:
		_draw_line(level.position, levels[0][0].position)
	for i in range(len(levels) - 2):  # Connect nodes between levels
		var current_level = levels[i]
		var next_level = levels[i + 1]
		
		for node in current_level:
			var target_node = next_level[randi() % next_level.size()]  # Pick a random node from the next level
			_draw_line(node.position, target_node.position)

func _draw_line(start_pos, end_pos):
	var line = Line2D.new()
	line.default_color = Color(1, 1, 1)  # White color
	line.width = 3  # Set line width
	line.add_point(start_pos)
	line.add_point(end_pos)
	add_child(line)



func _ready():
	_generate_map()
	_connect_nodes()
