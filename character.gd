extends AnimatedSprite2D

@export var current_node: Node2D  # Starting node (set in Inspector)
var target_node: Node2D = null

func _ready():
	if current_node == null:
		print("ERROR: current_node is not set! Assign it in the Inspector.")
		return
	global_position = current_node.global_position
	print("Character starts at:", current_node.name)
	
	# Set default animation to 'idle'
	$".".play("idle")

# Handle input for movement and special actions
func _input(event):
	if event is InputEventKey and event.pressed:
		var next_node = null

		if Input.is_action_pressed("up"):  # Move up to parent
			next_node = get_parent_node()
		elif Input.is_action_pressed("left"):  # Move to ChildNode1 or ChildNode3
			if current_node.name == "ChildNode1":
				next_node = get_child_by_name("ChildNode3")
			else:
				next_node = get_child_by_name("ChildNode1")
		elif Input.is_action_pressed("right"):  # Move to ChildNode2
			next_node = get_child_by_name("ChildNode2")
		elif Input.is_action_pressed("space"):  # Load battle.tscn if on ChildNode3
			if current_node.name == "ChildNode3":
				load_battle_scene()
				return  # Prevent movement when loading a new scene
			elif current_node.name == "ChildNode2":
				load_casino_scene()
				return # Prevent movement when loading a new scene

		if next_node:
			move_to(next_node)

# Find and return the parent node
func get_parent_node() -> Node2D:
	var parent = current_node.get_parent()
	
	# Prevent moving to root (Map)
	if parent and parent.name != "Map":
		return parent
	
	print("Cannot move to parent, staying at:", current_node.name)
	return null  # Don't move if the only parent is Map

# Find child node by name
func get_child_by_name(child_name: String) -> Node2D:
	for child in current_node.get_children():
		if child is Node2D and child.name == child_name:
			return child
	return null

# Move to the specified node
func move_to(new_node):
	if new_node and new_node != current_node:
		print("Moving from:", current_node.name, "to:", new_node.name, "at", new_node.global_position)

		# Create a tween animation
		var tween = get_tree().create_tween()
		tween.tween_property(self, "global_position", new_node.global_position, 1) # 1 seconds smooth move

		# Play 'walk' animation during movement
		$".".play("walk")

		# Flip sprite based on direction
		$".".flip_h = new_node.global_position.x < global_position.x

		# Set to 'idle' animation when tween is done
		tween.connect("finished", Callable(self, "_on_tween_finished"))

		# Update current node AFTER animation starts
		current_node = new_node

# Callback for tween completion
func _on_tween_finished():
	$".".play("idle")

func load_battle_scene():
	var battle_scene = ResourceLoader.load("res://battle_scene/battle_useable.tscn")  # Load the scene
	if battle_scene and battle_scene is PackedScene:
		print("Loading battle.tscn scene...")
		
		# Instantiate the new scene
		var new_scene = battle_scene.instantiate()
		
		# Get the current scene and remove it
		var current_scene = get_tree().get_current_scene()
		if current_scene:
			current_scene.queue_free()
		
		# Add the new scene as a child of the root viewport
		get_tree().root.add_child(new_scene)
		
		# Set the new scene as the current active scene
		get_tree().set_current_scene(new_scene)
	else:
		print("ERROR: Unable to load battle.tscn scene!")
		
func load_casino_scene(): 
	var casino_scene = ResourceLoader.load("res://Casino.tscn")
	
	if casino_scene and casino_scene is PackedScene: 
		var new_scene = casino_scene.instantiate()
		var current_scene = get_tree().get_current_scene()
		if current_scene:
			current_scene.queue_free()
		
		# Add the new scene as a child of the root viewport
		get_tree().root.add_child(new_scene)
		
		# Set the new scene as the current active scene
		get_tree().set_current_scene(new_scene)
	else:
		print("ERROR: Unable to load battle.tscn scene!")
	
