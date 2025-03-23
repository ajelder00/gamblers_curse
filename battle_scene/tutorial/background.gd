extends Sprite2D

# Variables for sway
@export var sway_speed : float = 0.5  # Speed of swaying (higher values = faster sway)
@export var sway_distance : float = 30.0  # Distance the sprite moves (pixels)

# Initial position offset
var initial_position : Vector2

# Called when the node enters the scene tree for the first time.
func _ready():
	initial_position = position  # Store the initial position of the sprite

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# Calculate the sway using a sine wave for smooth oscillation
	var sway = sin(Time.get_ticks_msec() / 1000.0 * sway_speed) * sway_distance
	
	# Update the sprite's x position to create the sway effect
	position.x = initial_position.x + sway
