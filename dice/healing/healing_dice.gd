extends Dice

func _ready():
	type = Dice.Type.HEALING
	$AnimatedSprite2D.modulate = Color(1, 0.5, 0.7, 1) # pink
	super._ready()
