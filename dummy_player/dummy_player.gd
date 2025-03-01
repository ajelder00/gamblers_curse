extends Node2D
@onready var parent = get_parent()

signal attack_signal
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Label.text = "Health: " + str(Global.player_health)

func hit():
	$Label.text = "Health: " + str(Global.player_health)
	var damage = $"Dice Roller".prev_total
	return damage

func get_hit(enemy_damage):
	$AnimatedSprite2D.play("get_hit")
	await $AnimatedSprite2D.animation_finished
	Global.player_health -= enemy_damage
	if Global.player_health < 0:
		Global.player_health = 0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func _on_dice_roller_turn_over() -> void:
	attack_signal.emit()
