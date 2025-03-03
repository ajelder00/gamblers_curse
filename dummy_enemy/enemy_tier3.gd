extends DummyEnemy

func initialize_enemy():
	health = 50
	tier_multiplier = 2
	enemy_type = "Tier 3"
	
	# Load different sprite animations
	sprite_variants = [
		preload("res://enemy_sprites/enemy3_variant1.tres"),
		preload("res://enemy_sprites/enemy3_variant2.tres")
	]
