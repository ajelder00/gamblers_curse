extends Dice

func _ready():
	type = Dice.Type.HEALING
	$AnimatedSprite2D.modulate = Color(1, 0.5, 0.7, 1) # pink
	super._ready()

func roll_die(faces) -> void:
	result = randi_range(1, faces)
	var dmg = Damage.create(0, status_effect, duration, type)
	rolling_animation(dmg)
	Global.player_health += result
	if Global.player_health > 100:
		Global.player_health = 100
	result = 0
	
