extends Dice

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	type = Dice.Type.FROZEN
	status_effect = Global.Status.FROZEN
	faces = 4
	cost = 15
	super._ready()

func roll_die(faces) -> void:
	
	result = randi_range(1, faces) #damage 1 - 4
	var accuracy = 0.6 + (0.1 * result)  
	accuracy = clamp(accuracy, 0.6, 1.0) #accuracy 60% - 100% 

	var dmg = Damage.create(result, status_effect, result, type, 1)
	rolling_animation(dmg)
