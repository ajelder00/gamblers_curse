extends ColorRect

const MAX_WIDTH: float = 266.0  # Maximum width of the health bar at full health
const MAX_HEALTH: float = 200.0  # Maximum player health

func _process(delta: float) -> void:
	# Get the current player health
	var player_health = Global.player_health  # Assuming Global stores player health

	# Calculate the new width based on health ratio
	var health_ratio = clamp(player_health / MAX_HEALTH, 0.0, 1.0)
	size.x = MAX_WIDTH * health_ratio  # Scale width dynamically
