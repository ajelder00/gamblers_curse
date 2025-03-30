extends Button

# Preload the map scene for better performance
const MAP_SCENE = preload("res://map_stuff/map_controller.tscn")
@onready var parent = get_parent()
@onready var anim_player = parent.get_node("AnimationPlayer")
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pressed.connect(_on_play_pressed)

# Function to load the map.tscn scene when the button is pressed
func _on_play_pressed() -> void:
	Global.reset()
	get_tree().change_scene_to_packed(MAP_SCENE)



func _on_mouse_entered() -> void:
	anim_player.play("big_play")



func _on_mouse_exited() -> void:
	anim_player.play("small_play")
