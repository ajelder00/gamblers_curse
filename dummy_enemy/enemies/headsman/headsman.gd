extends DummyEnemy


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	type = DummyEnemy.Type.AXEMAN
	base_accuracy = 0.75
	turns = 3
	health = 80
	tier = 3
	coins = int(randi_range(0,10)*randf_range(tier,tier + 1))
	super._ready()
