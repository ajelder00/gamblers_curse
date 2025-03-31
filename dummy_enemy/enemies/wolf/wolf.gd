extends DummyEnemy


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	base_accuracy = 1.0
	type = DummyEnemy.Type.WOLF
	dice_bucket = [$Dice]
	turns = 3
	health = 40
	tier = 2
	super._ready()
