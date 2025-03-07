extends ColorRect

const MAX_WIDTH: float = 308.0  # Maximum width of the health bar at full health
const MAX_HEALTH: float = 100.0  # Maximum enemy health

var enemy: Node  # Reference to the enemy

func _process(delta: float) -> void:
	if enemy:  # Ensure enemy exists before accessing health
		var health_ratio = clamp(enemy.health / MAX_HEALTH, 0.0, 1.0)
		size.x = MAX_WIDTH * health_ratio  # Scale width dynamically
		queue_redraw()  # Force a UI update

func set_enemy(new_enemy: Node) -> void:
	enemy = new_enemy  # Assign the enemy reference
	_update_health_bar()  # Immediately update the bar

func _update_health_bar() -> void:
	if enemy:
		var health_ratio = clamp(enemy.health / MAX_HEALTH, 0.0, 1.0)
		size.x = MAX_WIDTH * health_ratio
		queue_redraw()
