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


func _ready() -> void:
	Global.connect("player_healed", _on_healed)
	roller.turn_over.connect(_on_dice_roller_turn_over)
	sprite.play("idle")
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
	sprite.play("idle")

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

func floating_text(text: String, color: Color) -> void:
	var label = Label.new()
	label.text = text
	label.add_theme_color_override("font_color", color)
	label.add_theme_font_size_override("font_size", 30)
	add_child(label)
	
	label.position = Vector2(
		randf_range(label.position.x +50, label.position.x - 50),
		randf_range(label.position.y +30, label.position.y)
	)
	
	var tween = get_tree().create_tween()
	var target_position = label.position + Vector2(randi_range(-10, 10), -50)
	tween.tween_property(label, "position", target_position, 0.75).set_trans(Tween.TRANS_SINE)
	
	# Fade out
	tween.tween_property(label, "modulate", Color(1, 1, 1, 0), 0.75)
	await tween.finished
	label.queue_free()

func _on_healed(heal_amount):
	floating_text("+" + str(heal_amount), Color.GREEN_YELLOW)
	var tween = get_tree().create_tween()
	tween.tween_property(sprite, "modulate", Color(0.6, 1.0, 0.6), 0.5)  # Fade to light pink in 0.5s
	tween.tween_property(sprite, "modulate", Color(1.0, 1.0, 1.0), 0.5)  # Fade back to original in 0.5s
	
