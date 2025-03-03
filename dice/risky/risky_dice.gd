extends Dice
var side := 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	type = Dice.Type.RISKY
	super._ready()

func roll_die(faces) -> void:
	side = randi_range(1, faces)
	if side < 6:
		rolling_animation(0)
		result = 0
	else:
		rolling_animation(21)
		result = 21
	
