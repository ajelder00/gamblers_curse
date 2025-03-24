extends Dice
var side := 0

func _ready():
	type = Dice.Type.HEALING
	$AnimatedSprite2D.modulate = Color(1, 0.5, 0.7, 1) # pink
	super._ready()

func roll_die(faces) -> void:
	side = randi_range(1, faces)
	rolling_animation(side)
	Global.player_health += side
	if Global.player_health > 100:
		Global.player_health = 100
	result = 0
	
