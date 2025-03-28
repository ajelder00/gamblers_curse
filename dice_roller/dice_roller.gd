extends Node2D

signal turn_over
signal pop_over

@onready var ORIGINAL_ROLLS = 3
@onready var current_rolls = ORIGINAL_ROLLS
@onready var dice_bucket = Global.testing_dice
@onready var positions := get_children()
@onready var parent = get_parent()
var current_dice = []
var current_results := []


func _ready():
	# Grabs the positions from the battle scene
	if self.get_parent().get_parent():
		var battle = self.get_parent().get_parent()
		positions = battle.get_node("DiceBG").get_children()
		print("got it!")
	
	# this await function fixes the 1st die appearing above the UI for some reason
	await get_tree().create_timer(0.1).timeout
	first_turn()
	
	
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
		if i >= 5:
			die.get_node("Button").hide()
		await get_tree().create_timer(0.1).timeout
		die.rolled.connect(_on_die_rolled)
		
		# animation code
		# resets the die's animation to blank
		current_dice[i].animation_player.animation = current_dice[i].ANIMS[current_dice[i].type][0]
		current_dice[i].global_position = positions[i].global_position + Vector2(0, -20)
		if i < 5:
			current_dice[i].get_node("Button").show()
		
		var new_position = positions[i].global_position
		var tween_position = get_tree().create_tween()
		tween_position.tween_property(current_dice[i], "global_position", new_position, 0.2).set_trans(Tween.TRANS_SINE)
		
		var tween_transparency = get_tree().create_tween()
		tween_transparency.tween_property(current_dice[i], "modulate:a", 1, 0.2).set_trans(Tween.TRANS_SINE)


func _on_die_rolled(damage_packet: Damage):
	current_rolls -= 1
	current_results.append(damage_packet)
	
	print("Roll stats: damage:" + str(damage_packet.damage_number) + " type: " + str(damage_packet.type) + " duration: " + str(damage_packet.duration))
	if current_rolls == 0:
		for die in current_dice:
			die.get_node("Button").hide()
		turn_over.emit() 
		
		# for debugging purposes
		# await get_tree().create_timer(2).timeout
		# new_turn()


func new_turn():
	pop_dice()
	await pop_over
	reset_positions()
	current_rolls = ORIGINAL_ROLLS
	current_results = []
	
	
func pop_dice():
	var i = 0
	var amount_popped = 0
	
	while amount_popped < 3:
		if current_dice[i].is_rolled:
			# debug print statement
			print(i)
			
			#animation block
			var new_position = current_dice[i].global_position + Vector2(0, -20)
			var tween_position = get_tree().create_tween()
			tween_position.tween_property(current_dice[i], "global_position", new_position, 0.2).set_trans(Tween.TRANS_SINE)
			var tween_transparency = get_tree().create_tween()
			tween_transparency.tween_property(current_dice[i], "modulate:a", 0, 0.15)
			await get_tree().create_timer(0.1).timeout
			
			# Reset state
			current_dice[i].is_rolled = false
			current_dice.append(current_dice.pop_at(i))
			
			# Counters
			i -= 1
			amount_popped += 1
			
		i += 1
		
	# Signal for making sure the pop function is ran before the reset_positions() function is
	emit_signal("pop_over")


func reset_positions():
	# loop to push the dice to the right
	var last_index = 0
	for j in range(len(current_dice) - 3):
		await get_tree().create_timer(0.1).timeout
		
		var new_position = positions[j].global_position
		var tween_position = get_tree().create_tween()
		tween_position.tween_property(current_dice[j], "global_position", new_position, 0.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)

		# Makes first 5 selectable
		if j < 5:
			current_dice[j].get_node("Button").show()
		
		last_index = j
	
	
	for j in range(last_index, len(current_dice)):
		# makes dice that end up in the selectable 5 first dice selectable
		if j < 5:
			current_dice[j].get_node("Button").show()
		
		await get_tree().create_timer(0.1).timeout
		# resets the die's animation to blank
		current_dice[j].animation_player.animation = current_dice[j].ANIMS[current_dice[j].type][0]
		current_dice[j].global_position = positions[j].global_position + Vector2(0, -20)
		
		var new_position = positions[j].global_position
		var tween_position = get_tree().create_tween()
		tween_position.tween_property(current_dice[j], "global_position", new_position, 0.2).set_trans(Tween.TRANS_SINE)
		
		var tween_transparency = get_tree().create_tween()
		tween_transparency.tween_property(current_dice[j], "modulate:a", 1, 0.2).set_trans(Tween.TRANS_SINE)
