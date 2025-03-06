extends Dice

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	status_effect = [Global.Status.POISON, duration]
	type = Dice.Type.POISON
	faces = 3
	super._ready()
