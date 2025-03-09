extends ColorRect

const MAX_WIDTH: float = 308.0  # Maximum width of the health bar at full health
const ENEMY_SCENE = preload("res://dummy_enemy/dummy_enemy.tscn")  # Update with actual path

var enemy: Node  # Will store the instantiated enemy

func _ready() -> void:
	instantiate_enemy()

func instantiate_enemy() -> void:
	enemy = ENEMY_SCENE.instantiate()  # Create an instance of the enemy
	add_child(enemy)  # Add it as a child of the health bar (or reparent it elsewhere)
	enemy.health = enemy.MAX_HEALTH  # Ensure full health at the start

func _process(delta: float) -> void:
	if enemy:  # Ensure an enemy exists before updating
		var health_ratio = clamp(enemy.health / enemy.MAX_HEALTH, 0.0, 1.0)
		size.x = MAX_WIDTH * health_ratio  # Scale width dynamically

		# Force a UI update to reflect changes
		queue_redraw()
