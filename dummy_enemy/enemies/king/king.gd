extends DummyEnemy


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	base_accuracy = 1.0
	dice_bucket = [$Dice]
	type = DummyEnemy.Type.KING
	turns = 2
	health = 70
	tier = 2
	coins = int(randi_range(0,10)*randf_range(tier,tier + 1))
	super._ready()
