extends Dice

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	type = Dice.Type.CHAR
	status_effect = Global.Status.NOTHING
	faces = 1
	cost = 1
	super._ready()

func roll_die(faces) -> void:
	result = randi_range(1, faces)
	var dmg = Damage.create(result, status_effect, duration, type, 1)
	rolling_animation(dmg)
