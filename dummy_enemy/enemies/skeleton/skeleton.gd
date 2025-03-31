extends DummyEnemy


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	type = DummyEnemy.Type.SKELETON
	immunities = [Dice.Type.POISON]
	dice_bucket = [$Dice]
	turns = 2
	health = 40
	tier = 1
	super._ready()
