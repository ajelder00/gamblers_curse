extends Dice

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$AnimatedSprite2D.modulate = Color(1, 0, 0)
	status_effect = Global.Status.BLEEDING
	type = Dice.Type.STANDARD
	faces = 6
	super._ready()

func roll_die(faces) -> void:
	result = randi_range(1, faces)
	var dmg = Damage.create(result, status_effect, result, type, (result/faces))
	rolling_animation(dmg)
