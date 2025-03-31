extends DummyEnemy


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	base_accuracy = 1.0
	immunities = [Dice.Type.POISON]
	type = DummyEnemy.Type.WIZARD
	dice_bucket = [$Dice, $Dice2]
	turns = 3
	health = 60
	tier = 3
	super._ready()
