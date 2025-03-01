extends ColorRect

var max_health: int = 10

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if "player_health" in get_tree().get_root():  # Ensure the variable exists
		var health_ratio = float(get_tree().get_root().player_health) / max_health
		size.x = 100 * health_ratio  # Adjust 100 to the max width of the bar
