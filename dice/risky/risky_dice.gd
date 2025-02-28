extends Dice


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	type = Dice.Type.RISKY
	$AnimatedSprite.modulate = Color(1, 0, 0)  # Pure red

func roll_die(faces) -> void:
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
