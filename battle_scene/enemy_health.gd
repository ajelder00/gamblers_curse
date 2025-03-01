extends ColorRect

var initial_width: float
var target_width: float

func _ready() -> void:
	initial_width = size.x  
	target_width = initial_width  

func _process(delta: float) -> void:
	if randf() < 0.05:  # Occasionally change the target width
		target_width = randf_range(0.2, 1.0) * initial_width  

	size.x = lerp(size.x, target_width, delta * 5)  # Smooth transition
