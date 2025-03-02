extends Dice

func _ready() -> void:
	type = Dice.Type.STANDARD
	
	#code for hiding the button 
	$Button.self_modulate.a = 0 
	$Label.hide()
	result = 0

# Called when the node enters the scene tree for the first time.
func roll_die(faces) -> void:
	var roll = randi_range(1, faces)
	result = roll
	emit_signal("rolled")
	$AnimatedSprite2D.animation = "roll_standard"
	$AnimatedSprite2D.play()
	await $AnimatedSprite2D.animation_finished
	$AnimatedSprite2D.stop()
	$Label.text = "You rolled a " + str(roll)
	$AnimatedSprite2D.animation = "faces_standard"
	$AnimatedSprite2D.frame = roll - 1


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
