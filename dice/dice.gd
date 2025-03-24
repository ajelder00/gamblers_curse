class_name Dice
extends Node2D

var result
var status_effect = [Global.Status.NOTHING, duration]

enum Type{STANDARD, RISKY, DEIGHT, POISON, SPLIT, HYPNOSIS, 
	HEALING, BERSERK, VAMPIRE, SHIELD, ROCK, BLIND,
	DTWO, RUSSIAN, DONEHUNDRED
	}

const ANIMS := {
	Type.STANDARD: ["blank_standard", "roll_standard", "faces_standard"],
	Type.RISKY: ["blank_risky", "roll_risky", "faces_risky"],
	Type.POISON: ["blank_poison", "roll_poison", "faces_poison"],
	Type.HEALING: ["blank_standard", "roll_standard", "faces_standard"]
}
const TYPE_NAMES := {
	Type.STANDARD: ["Standard"],
	Type.RISKY: ["Risky"],
	Type.POISON: ["Poison"],
	Type.HEALING: ["Healing"]
}

signal rolled(value: int, effect: Array)

var type: Type = Type.STANDARD
var original_scale = scale

@onready var animation_player := $AnimatedSprite2D
@onready var button := $Button
@onready var faces := 6
@onready var duration := 3

# Sound effects
@onready var roll_sound = AudioStreamPlayer.new()
@onready var roll_sound_path = load("res://dice/dice_sounds/01_chest_open_2.wav")
@onready var name_label = $NameLabel  # Reference to the Label node you want to show/hide

func _ready():
	animation_player.animation = ANIMS[type][0]
	button.self_modulate.a = 0 
	result = 0
	
	# Sound set up
	add_child(roll_sound)
	roll_sound.stream = roll_sound_path
	
	# Initially hide the name label
	name_label.visible = false

func _on_button_pressed() -> void:
	roll_sound.play()
	roll_die(faces)
	button.hide()

func roll_die(faces) -> void:
	result = randi_range(1, faces)
	rolling_animation(result)

func rolling_animation(roll) -> void:
	print("Rolled a " + str(roll))
	emit_signal("rolled", roll, status_effect)
	animation_player.animation = ANIMS[type][1]
	animation_player.play()
	await animation_player.animation_finished
	animation_player.stop()
	animation_player.animation = ANIMS[type][2]
	animation_player.frame = roll - 1

# Show the label with dice name when mouse enters button
func _on_button_mouse_entered() -> void:
	name_label.text = TYPE_NAMES[type][0]  # Show the dice type name in the label
	name_label.visible = true  # Make the label visible
	var tween = get_tree().create_tween()
	tween.tween_property(self, "scale", original_scale * 1.2, 0.2).set_trans(Tween.TRANS_SINE)

# Hide the label when mouse exits the button
func _on_button_mouse_exited() -> void:
	name_label.visible = false  # Hide the label when the mouse exits
	var tween = get_tree().create_tween()
	tween.tween_property(self, "scale", original_scale, 0.2).set_trans(Tween.TRANS_SINE)

func get_parent_node():
	return get_parent()
