extends DummyEnemy


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	type = DummyEnemy.Type.GOBLIN
	dice_bucket = [$Dice]
	base_accuracy = 1.0
	turns = 1
	health = 50
	tier = 1
	super._ready()
