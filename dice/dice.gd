extends Node2D

var result
signal rolled
@onready var original_scale = scale

func _ready():
	$AnimatedSprite2D.animation = "blank"
	$Button.self_modulate.a = 0 
	$Label.hide()
	result = 0
	

func roll_die(faces = 6):
	var roll = randi_range(1, faces)
	result = roll
	emit_signal("rolled")
	$AnimatedSprite2D.animation = "roll"
	$AnimatedSprite2D.play()
	await $AnimatedSprite2D.animation_finished
	$AnimatedSprite2D.stop()
	$Label.text = "You rolled a " + str(roll)
	$AnimatedSprite2D.animation = "faces"
	$AnimatedSprite2D.frame = roll - 1


func _on_button_pressed() -> void:
	roll_die()


func _on_button_mouse_entered() -> void:
	var tween = get_tree().create_tween()
	tween.tween_property(self, "scale", original_scale * 1.2, 0.2).set_trans(Tween.TRANS_SINE)


func _on_button_mouse_exited() -> void:
	var tween = get_tree().create_tween()
	tween.tween_property(self, "scale", original_scale, 0.2).set_trans(Tween.TRANS_SINE)
