extends Node2D

@onready var parent = get_parent()
@onready var roller = $"Dice Roller"
@onready var sprite = $"AnimatedSprite2D"

# Music stuff
@onready var attack_sound = AudioStreamPlayer.new()
@onready var attack_sound_path = load("res://dummy_player/dummy_player_sounds/07_human_atk_sword_2.wav")
@onready var hit_sound = AudioStreamPlayer.new()
@onready var hit_sound_path = load("res://dummy_player/dummy_player_sounds/11_human_damage_1.wav")

var dice_effects := []

signal attack_signal
# Called when the node enters the scene tree for the first time.
signal damage_over

func _ready() -> void:
	roller.turn_over.connect(_on_dice_roller_turn_over)
	
	# Adding music as children and setting path
	add_child(attack_sound)
	attack_sound.stream = attack_sound_path
	add_child(hit_sound)
	hit_sound.stream = hit_sound_path

func hit() -> Array :
	return roller.current_results

func get_hit(enemy_damage: Damage):
	sprite.play("get_hit")
	hit_sound.play()
	Global.player_health = max(0, Global.player_health - enemy_damage.damage_number)
	parent.update_health_display()
	await sprite.animation_finished

	if Global.player_health < 0:
		Global.player_health = 0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func _on_dice_roller_turn_over() -> void:
	attack_sound.play()
	attack_signal.emit()

# Plays the attack sound, as a function since battle is going to call it
# Prevents the need to create another path to a child of player
func play_attack_sound():
	attack_sound.play()
