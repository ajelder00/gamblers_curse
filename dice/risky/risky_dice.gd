extends Dice


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	type = Dice.Type.RISKY
	super._ready()

func roll_die(faces) -> void:
	var result = randi_range(1, faces)
	if result < 6:
		rolling_animation(0)
	else:
		rolling_animation(21)
