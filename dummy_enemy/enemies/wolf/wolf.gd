extends DummyEnemy


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	base_accuracy = 1.0
	type = DummyEnemy.Type.WOLF
	dice = $Dice
	dice_button = $Dice/Button
	turns = 3
	health = 60
	tier = 2
	coins = int(randi_range(0,10)*randf_range(tier,tier + 1))
	super._ready()
