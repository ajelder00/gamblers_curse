extends Dice

func _ready():
	type = Dice.Type.HEALING
	faces = 12
	cost = 12
	super._ready()

func roll_die(faces) -> void:
	var dmg
	result = randi_range(1, faces)
	if not result == 1:
		dmg = Damage.create(result, status_effect, duration, type)
	else:
		dmg = Damage.create(((200 - Global.player_health)/2), status_effect, duration, type)
	rolling_animation(dmg)
