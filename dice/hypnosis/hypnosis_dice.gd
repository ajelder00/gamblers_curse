extends Dice

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	type = Dice.Type.HYPNOSIS
	status_effect = Global.Status.HYPNOSIS
	faces = 6
	cost = 17
	super._ready()

func roll_die(faces) -> void:
	result = randi_range(1, faces)

	var damage = int(ceil(result /2)) # damage 1 - 3  
	var duration = int(ceil(result /3)) # duration 1 - 2  
	var accuracy = 1.0 #float(result) / float(faces)  # 0.17–1.0

	var dmg = Damage.create(damage, status_effect, duration, type)
	rolling_animation(dmg)
