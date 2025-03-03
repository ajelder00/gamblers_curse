extends DummyEnemy

func initialize_enemy():
	health = 10
	tier_multiplier = 1
	enemy_type = "Tier 1"
	
	# Load different sprite animations
	sprite_variants = [
		preload("res://enemy_sprites/enemy1_variant1.tres"),
		preload("res://enemy_sprites/enemy1_variant2.tres"), 
		preload("res://enemy_sprites/enemy1_variant3.tres")
	]
