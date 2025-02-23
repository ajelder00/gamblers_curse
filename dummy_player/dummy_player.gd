extends Node2D
@onready var parent = get_parent()
var health = 100
signal attack_signal
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Label.text = "Health: " + str(health)

func hit():
	$Label.text = "Health: " + str(health)
	$AnimatedSprite2D.play("attack")
	var damage = $Dice.result
	return damage

func get_hit(enemy_damage):
	$AnimatedSprite2D.play("get_hit")
	await $AnimatedSprite2D.animation_finished
	self.health -= enemy_damage
	if self.health < 0:
		self.health = 0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _on_dice_rolled() -> void:
	attack_signal.emit()
