extends Node2D
var health = 10

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Label.text = "Health: " + str(health)
	$AnimatedSprite2D.flip_h = true
	$Dice/Button.hide()
	

func hit():
	$Label.text = "Health: " + str(health)
	$AnimatedSprite2D.animation = "attack"
	$AnimatedSprite2D.play()
	$Dice.roll_die()
	var damage = $Dice.result
	return damage

func get_hit(enemy_damage):
	$AnimatedSprite2D.play("get_hit")
	await $AnimatedSprite2D.animation_finished
	self.health -= enemy_damage
	if self.health < 0:
		self.health = 0

# Called every frame. 'delta' is the elapsed time since the previous frame.
