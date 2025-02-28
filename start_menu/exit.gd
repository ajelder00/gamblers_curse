extends Button
@onready var parent = get_parent()
@onready var anim_player = parent.get_node("AnimationPlayer")
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pressed.connect(_on_exit_pressed)

# Function to load the map.tscn scene when the button is pressed
func _on_exit_pressed() -> void:
	get_tree().quit()



func _on_mouse_entered() -> void:
	anim_player.play("big_exit")



func _on_mouse_exited() -> void:
	anim_player.play("small_exit")
