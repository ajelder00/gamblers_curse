extends DummyEnemy


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	type = DummyEnemy.Type.SLIME
	immunities = [Dice.Type.POISON, Dice.Type.HYPNOSIS, Dice.Type.BLIND]
	dice_bucket = [$Dice]
	turns = 3
	health = 20
	tier = 1
	super._ready()
