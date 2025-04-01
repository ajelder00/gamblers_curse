extends Dice

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	type = Dice.Type.FIRE
	status_effect = Global.Status.FIRE
	faces = 6
	cost = 17
	super._ready()

func roll_die(faces) -> void:
	result = randi_range(1, faces)
	var dmg = Damage.create(result, status_effect, max(1, result - 3), type, float(float(result)/float(faces)))
	rolling_animation(dmg)
