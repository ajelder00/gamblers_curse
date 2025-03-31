extends DummyEnemy


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	type = DummyEnemy.Type.AXEMAN
	base_accuracy = 0.75
	dice_bucket = [$Dice]
	turns = 3
	health = 80
	tier = 3
	super._ready()
