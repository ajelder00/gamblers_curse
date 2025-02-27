extends Button

# Preload the map scene for better performance
const MAP_SCENE = preload("res://map_stuff/map_tutorial_stuff/map.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Connect the button's pressed signal to the function
	pressed.connect(_on_Play_pressed)

# Function to load the map.tscn scene when the button is pressed
func _on_Play_pressed() -> void:
	get_tree().change_scene_to_packed(MAP_SCENE)
