extends Dice

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	type = Dice.Type.DROWNING
	status_effect = Global.Status.DROWNING
	faces = 6
	cost = 12
	super._ready()

func roll_die(faces) -> void:
	#result = 6
	result = randi_range(4, faces)
	var dmg = Damage.create(result - 3, status_effect, result, type, float(float(result)/float(faces)))
	rolling_animation(dmg)
