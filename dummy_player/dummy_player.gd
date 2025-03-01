extends Node2D
@onready var parent = get_parent()
@onready var dice: Dice = $StandardDice
signal attack_signal
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Label.text = "Health: " + str(Global.player_health)

func hit():
	$Label.text = "Health: " + str(Global.player_health)
	$AnimatedSprite2D.play("attack")
	var damage = dice
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


func _on_dice_rolled() -> void:
	attack_signal.emit()
