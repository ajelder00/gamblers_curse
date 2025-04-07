class_name Dice
extends Node2D

var result
var status_effect := Global.Status.NOTHING

enum Type{STANDARD, RISKY, DEIGHT, POISON, SPLIT, HYPNOSIS, 
	HEALING, BERSERK, VAMPIRE, SHIELD, ROCK, BLIND,
	DTWO, RUSSIAN, DONEHUNDRED, DROWNING, FIRE, CHAR, CHANCE, FROZEN
	}

const ANIMS := {
	Type.STANDARD: ["blank_standard", "roll_standard", "faces_standard"],
	Type.RISKY: ["blank_risky", "roll_risky", "faces_risky"],
	Type.POISON: ["blank_poison", "roll_poison", "faces_poison"],
	Type.HEALING: ["blank_healing", "roll_healing", "faces_healing"],
	Type.BLIND: ["blank_blind", "roll_blind", "faces_blind"],
	Type.DROWNING: ["blank_drowning", "roll_drowning", "faces_drowning"],
	Type.FIRE: ["blank_fire", "roll_fire", "faces_fire"],
	Type.CHAR: ["blank_char", "roll_char", "faces_char"], 
	Type.CHANCE: ["blank_chance", "roll_chance", "faces_chance"], 
	Type.HYPNOSIS: ["blank_hypnosis", "roll_hypnosis", "faces_hypnosis"],
	Type.FROZEN: ["blank_frozen", "roll_frozen", "faces_frozen"]
}

const TYPE_NAMES := {
	Type.STANDARD: ["Standard"],
	Type.RISKY: ["Risky"],
	Type.POISON: ["Poison"],
	Type.HEALING: ["Healing"],
	Type.BLIND: ["Blinding"],
	Type.DROWNING: ["Water"],
	Type.FIRE: ["Fire"],
	Type.CHAR: ["Charred"], 
	Type.CHANCE: ["Chance"], 
	Type.HYPNOSIS: ["Hypnosis"], 
	Type.FROZEN: ["Frozen"]
}

signal rolled(damage_packet: Damage)

var type: Type = Type.STANDARD
var original_scale = scale

@onready var animation_player := $AnimatedSprite2D
@onready var button := $Button
@onready var faces := 6
@onready var duration := 3
@onready var cost := 10
# for dice roller
@onready var is_rolled := false

# Sound effects
@onready var roll_sound = AudioStreamPlayer.new()
@onready var roll_sound_path = load("res://dice/dice_sounds/01_chest_open_2.wav")
@onready var name_label = $NameLabel  # Reference to the Label node you want to show/hide

func _ready():
	var animation_player := $AnimatedSprite2D
	animation_player.animation = ANIMS[type][0]
	button.self_modulate.a = 0 
	result = 0
	
	# Sound set up
	add_child(roll_sound)
	roll_sound.stream = roll_sound_path
	
	# Initially hide the name label
	name_label.visible = false

func _on_button_pressed() -> void:
	is_rolled = true
	roll_sound.play()
	roll_die(faces)
	button.hide()
	if not get_parent().dont_gray:
		await animation_player.animation_finished
		self.deactivate()

func roll_die(faces) -> void:
	result = randi_range(1, faces)
	var dmg = Damage.create(result, status_effect, duration, type)
	rolling_animation(dmg)

func rolling_animation(roll) -> void:
	print("Rolled a " + str(roll.damage_number))
	emit_signal("rolled", roll)
	animation_player.animation = ANIMS[type][1]
	animation_player.play()
	await animation_player.animation_finished
	animation_player.stop()
	animation_player.animation = ANIMS[type][2]
	animation_player.frame = roll.damage_number - 1

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

func activate():
	animation_player.modulate = Color(1, 1, 1, 1)
	button.show()
	button.mouse_filter = Control.MOUSE_FILTER_STOP
	
func deactivate():
	button.hide()
	if animation_player.is_playing():
		await animation_player.animation_finished
		await get_tree().create_timer(.2).timeout
	await get_tree().create_timer(.1).timeout
	animation_player.modulate = Color(0.5, 0.5, 0.5, 1)
	button.mouse_filter = Control.MOUSE_FILTER_PASS
