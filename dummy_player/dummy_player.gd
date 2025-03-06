extends Node2D

@onready var parent = get_parent()
@onready var roller = $"Dice Roller"
@onready var sprite = $"AnimatedSprite2D"

var dice_effects := []

signal attack_signal
# Called when the node enters the scene tree for the first time.


func _ready() -> void:
	roller.turn_over.connect(_on_dice_roller_turn_over)

func hit() -> Array :
	var damage = roller.turn_total
	return [damage, dice_effects]

func get_hit(enemy_damage):
	sprite.play("get_hit")
	await sprite.animation_finished
	Global.player_health -= enemy_damage[0]
	if Global.player_health < 0:
		Global.player_health = 0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func _on_dice_roller_turn_over() -> void:
	attack_signal.emit()
