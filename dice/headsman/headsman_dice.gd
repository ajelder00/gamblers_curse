extends Dice

func roll_die(faces) -> void:
	result = randi_range(5, 6)
	var dmg = Damage.create(result, status_effect, duration, type)
	rolling_animation(dmg)
