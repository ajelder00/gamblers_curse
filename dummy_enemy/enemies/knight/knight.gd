extends DummyEnemy


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	base_accuracy = 1.0
	dice_bucket = [$Dice]
	type = DummyEnemy.Type.KNIGHT
	turns = 2
	health = 70
	tier = 2
	super._ready()
	
