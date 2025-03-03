extends DummyEnemy

func initialize_enemy():
	health = 30
	tier_multiplier = 2
	enemy_type = "Tier 2"
	
	# Load different sprite animations
	sprite_variants = [
		preload("res://enemy_sprites/enemy2_variant1.tres"),
		preload("res://enemy_sprites/enemy2_variant2.tres"), 
		preload("res://enemy_sprites/enemy2_variant3.tres")
	]
