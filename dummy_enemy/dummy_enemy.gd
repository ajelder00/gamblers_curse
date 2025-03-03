extends Node2D
class_name DummyEnemy  


var health: int 
var tier_multiplier: int 
var enemy_type: String 
var sprite_variants: Array  # Array of `SpriteFrames` resources


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	initialize_enemy()
	$Label.text = "Health: " + str(health)
	$AnimatedSprite2D.flip_h = true
	$Dice/Button.hide()
	assign_random_sprite()
	
func assign_random_sprite():
	if sprite_variants.size() > 0:
		var random_sprite = sprite_variants[randi() % sprite_variants.size()]
		$AnimatedSprite2D.sprite_frames = random_sprite  # Load random sprite frames
		var animations = $AnimatedSprite2D.sprite_frames.get_animation_names()
		$AnimatedSprite2D.animation = animations[0]
		$AnimatedSprite2D.play()

func hit():
	$Label.text = "Health: " + str(health)
	$AnimatedSprite2D.animation = "attack"
	$AnimatedSprite2D.play()
	$Dice.roll_die(6)
	var damage = $Dice.result * tier_multiplier
	return damage

func get_hit(enemy_damage):
	$AnimatedSprite2D.play("get_hit")
	await $AnimatedSprite2D.animation_finished
	self.health -= enemy_damage
	if self.health < 0:
		self.health = 0
	$Label.text = "Health: " + str(health)

# Function to initialize enemy values (to be overridden by subclasses)
func initialize_enemy():
	pass
