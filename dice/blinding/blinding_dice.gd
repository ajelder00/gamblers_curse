extends Dice

func _ready() -> void:
	status_effect = Global.Status.BLINDNESS
	type = Dice.Type.BLIND
	faces = 3
	super._ready()

func roll_die(faces) -> void:
	result = randi_range(1, faces)
	var dmg = Damage.create(result, status_effect, result, type)
	rolling_animation(dmg)
