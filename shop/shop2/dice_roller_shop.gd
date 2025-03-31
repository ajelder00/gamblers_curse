extends DiceRoller

func _ready() -> void:
	super._ready()
	dont_gray = true

func first_turn():
	current_dice = []
	current_results = []
	current_rolls = ORIGINAL_ROLLS
	
	
	for i in len(dice_bucket):
		# instantiate dice node
		# var index = randi_range(0, len(dice_bucket)-1)
		var die = dice_bucket[i].instantiate()
		die.modulate.a = 0
		add_child(die)
		die.global_position = positions[i].global_position
		current_dice.append(die)
		# hide function to prevent player from clicking on last 5 dice
		await get_tree().create_timer(0.1).timeout
		die.rolled.connect(_on_die_rolled)
		
		# animation code
		# resets the die's animation to blank
		current_dice[i].animation_player.animation = current_dice[i].ANIMS[current_dice[i].type][0]
		current_dice[i].global_position = positions[i].global_position + Vector2(0, -20)
		
		var new_position = positions[i].global_position
		var tween_position = get_tree().create_tween()
		tween_position.tween_property(current_dice[i], "global_position", new_position, 0.2).set_trans(Tween.TRANS_SINE)
		
		var tween_transparency = get_tree().create_tween()
		tween_transparency.tween_property(current_dice[i], "modulate:a", 1, 0.2).set_trans(Tween.TRANS_SINE)

func _on_die_rolled(damage_packet: Damage):
	pass

func reset_positions():
	# loop to push the dice to the right
	var last_index = 0
	for j in range(len(current_dice)):
		await get_tree().create_timer(0.1).timeout
		
		var new_position = positions[j].global_position
		var tween_position = get_tree().create_tween()
		tween_position.tween_property(current_dice[j], "global_position", new_position, 0.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)

	
	if len(current_dice) <= 3:
		for die in current_dice:
			die.button.hide()
	else:
		for die in current_dice:
			die.button.show()
	
func add_new_dice(dice_to_add):
	var die = dice_to_add.instantiate()
	die.modulate.a = 0
	add_child(die)
	die.global_position = positions[len(current_dice)].global_position
	current_dice.append(die)
	die.modulate.a = 1

	var grandparent = get_parent().get_parent()
	die.rolled.connect(grandparent._on_die_rolled.bind(die))
	if len(current_dice) >= 10:
		for node in get_parent().get_parent().to_buy:
			if is_instance_valid(node):
				node.dice.button.hide()
	if len(current_dice) > 3:
		for dice in current_dice:
			dice.button.show()
