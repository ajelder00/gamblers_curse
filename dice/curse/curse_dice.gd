extends Dice

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$AnimatedSprite2D.modulate = Color(0.6, 0.2, 0.8)
	status_effect = Global.Status.CURSE
	type = Dice.Type.STANDARD
	faces = 8
	super._ready()

func roll_die(faces) -> void:
	result = randi_range(1, faces)
	var dmg = Damage.create(result, status_effect, max(int(result / 2), 1), type, 0.25)
	rolling_animation(dmg)
