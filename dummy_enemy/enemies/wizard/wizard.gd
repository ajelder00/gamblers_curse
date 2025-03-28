extends DummyEnemy


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	base_accuracy = 1.0
	immunities = [Dice.Type.POISON]
	dice_bag = [$Dice, $Dice2]
	type = DummyEnemy.Type.WIZARD
	dice = $Dice
	dice_button = $Dice/Button
	turns = 3
	health = 60
	tier = 3
	coins = int(randi_range(0,10)*randf_range(tier,tier + 1))
	super._ready()
