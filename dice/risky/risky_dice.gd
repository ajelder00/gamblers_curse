extends Dice
var side := 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	type = Dice.Type.RISKY
	super._ready()

func roll_die(faces) -> void:
	side = randi_range(1, faces)
	if side < 6:
		var dmg = Damage.create(0, status_effect, duration, type)
		rolling_animation(dmg)
	else:
		var dmg = Damage.create(21, status_effect, duration, type)
		rolling_animation(dmg)
	
