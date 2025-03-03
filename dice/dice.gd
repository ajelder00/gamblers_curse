class_name Dice
extends Node2D

var result

enum Type{STANDARD, RISKY, DEIGHT, POISON, SPLIT, HYPNOSIS, 
	HEALING, BERSERK, VAMPIRE, SHIELD, ROCK, BLIND,
	DTWO, RUSSIAN, DONEHUNDRED
	}

const ANIMS := {
	Type.STANDARD: ["blank_standard", "roll_standard", "faces_standard"],
	Type.RISKY: ["blank_risky", "roll_risky", "faces_risky"]
}


signal rolled

@export var type: Type = Type.STANDARD
@export var original_scale = scale

@onready var label := $Label
@onready var animation_player := $AnimatedSprite2D
@onready var button := $Button
@onready var faces := 6

func _ready():
	animation_player.animation = ANIMS[type][0]
	button.self_modulate.a = 0 
	label.hide()
	result = 0
	
	

func roll_die(faces) -> void:
	result = randi_range(1, faces)
	rolling_animation(result)

	
	
func rolling_animation(roll) -> void:
	print(str(roll) + "dog woof")
	emit_signal("rolled")
	animation_player.animation = ANIMS[type][1]
	animation_player.play()
	await animation_player.animation_finished
	animation_player.stop()
	label.text = "You rolled a " + str(roll)
	animation_player.animation = ANIMS[type][2]
	animation_player.frame = roll - 1

func _on_button_pressed() -> void:
	roll_die(faces)
	button.hide()


func _on_button_mouse_entered() -> void:
	var tween = get_tree().create_tween()
	tween.tween_property(self, "scale", original_scale * 1.2, 0.2).set_trans(Tween.TRANS_SINE)


func _on_button_mouse_exited() -> void:
	var tween = get_tree().create_tween()
	tween.tween_property(self, "scale", original_scale, 0.2).set_trans(Tween.TRANS_SINE)
	
func get_parent_node():
	return get_parent()
