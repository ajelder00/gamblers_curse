extends Dice

func _ready() -> void:
	faces = 6
	cost = 5
	type = Dice.Type.STANDARD
	super._ready()
