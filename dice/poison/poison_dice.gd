extends Dice

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	type = Dice.Type.POISON
	status_effect = Global.Status.POISON
	faces = 3
	super._ready()

func roll_die(faces) -> void:
	result = randi_range(1, faces)
	var dmg = Damage.create(result, status_effect, result, type, float(float(result)/float(faces)))
	rolling_animation(dmg)
