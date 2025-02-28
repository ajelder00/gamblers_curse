extends Sprite2D

@export var amplitude: float = 10.0  # Controls the bobbing height
@export var speed: float = 2.5       # Controls how fast it bobs

var base_y: float = 0.0
var time: float = 0.0

func _ready() -> void:
	base_y = position.y  # Store the original y position

func _process(delta: float) -> void:
	time += delta * speed
	position.y = base_y + sin(time) * amplitude
