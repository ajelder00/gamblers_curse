extends Dice

func _ready():
	type = Dice.Type.HEALING
	faces = 12
	super._ready()
