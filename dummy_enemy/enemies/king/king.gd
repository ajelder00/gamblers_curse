extends DummyEnemy


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	base_accuracy = 1.0
	dice_bucket = [$Dice, $Dice2, $Dice3]
	type = DummyEnemy.Type.KING
	turns = 4
	health = 100
	tier = 4
	coins = int(randi_range(0,10)*randf_range(tier,tier + 1))
	super._ready()

func _on_die_rolled(damage_packet: Damage):
	dice.visible = true
	if accuracy >= randf_range(0, 1):
		damage = damage_packet
		await dice.animation_player.animation_finished
		if damage.damage_number < dice.faces - 2:
			floating_text("BENDING FATE", Color.DARK_GOLDENROD)
			await get_tree().create_timer(1).timeout
			dice.animation_player.animation = dice.ANIMS[dice.type][1]
			dice.animation_player.play()
			await get_tree().create_timer(0.5).timeout
			damage.damage_number = dice.faces - randi_range(0, 2)
			dice.animation_player.stop()
			dice.animation_player.animation = dice.ANIMS[dice.type][2]
			dice.animation_player.frame = (damage.damage_number) - 1
	else: 
		damage =  Damage.create(0, Global.Status.NOTHING, 0, dice.type)
	damage_to_player.emit(damage)
	attack_sound.play()
	sprite.play(ANIMS[type][0])
	await sprite.animation_finished
	sprite.play(ANIMS[type][3])
