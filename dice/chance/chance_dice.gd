extends Dice
var side := 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	cost = 15
	type = Dice.Type.CHANCE
	super._ready()

func roll_die(faces) -> void:
	side = randi_range(1, 2)
	if side < 2:
		var dmg = Damage.create(999, status_effect, duration, type)
		rolling_animation(dmg)
	else:
		var dmg = Damage.create(-999, status_effect, duration, type)
		rolling_animation(dmg)
	
