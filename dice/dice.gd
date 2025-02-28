class_name Dice
extends Node2D

var result
enum Type{STANDARD, RISKY, DEIGHT, POISON, SPLIT, HYPNOSIS, 
	HEALING, BERSERK, VAMPIRE, SHIELD, ROCK, BLIND,
	DTWO, RUSSIAN, DONEHUNDRED
	}
signal rolled

@onready var type: Type
@onready var original_scale = scale
@onready var faces := 6

func _ready():
	$AnimatedSprite2D.animation = "blank"
	$Button.self_modulate.a = 0 
	$Label.hide()
	result = 0
	

func roll_die(faces) -> void:
	pass


func _on_button_pressed() -> void:
	roll_die(faces)


func _on_button_mouse_entered() -> void:
	var tween = get_tree().create_tween()
	tween.tween_property(self, "scale", original_scale * 1.2, 0.2).set_trans(Tween.TRANS_SINE)


func _on_button_mouse_exited() -> void:
	var tween = get_tree().create_tween()
	tween.tween_property(self, "scale", original_scale, 0.2).set_trans(Tween.TRANS_SINE)
