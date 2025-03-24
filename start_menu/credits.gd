extends Button

@onready var parent = get_parent()
@onready var anim_player = parent.get_node("AnimationPlayer")  # Keep the original reference to AnimationPlayer
@onready var overlay = parent.get_node("Overlay")  # Get the "Overlay" child node

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pressed.connect(_on_credits_pressed)
	overlay.visible = false

# Function to create and display the credits overlay when the button is pressed
func _on_credits_pressed() -> void:
	overlay.visible = true
	

# Function to handle mouse enter/exit and play animations
func _on_mouse_entered() -> void:
	if anim_player:  # Ensure anim_player is valid before trying to play the animation
		anim_player.play("big_credits")

func _on_mouse_exited() -> void:
	if anim_player:  # Ensure anim_player is valid before trying to play the animation
		anim_player.play("small_credits")
