extends Node

func _input(event):
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		print("Returning to the map...")
		return_to_map()

func return_to_map():
	var map_scene = ResourceLoader.load("res://map.tscn")  # Load the map scene
	if map_scene and map_scene is PackedScene:
		# Instantiate and switch to the map scene
		var new_scene = map_scene.instantiate()
		var current_scene = get_tree().get_current_scene()
		if current_scene:
			current_scene.queue_free()
		get_tree().root.add_child(new_scene)
		get_tree().set_current_scene(new_scene)
	else:
		print("ERROR: Unable to load map.tscn scene!")
