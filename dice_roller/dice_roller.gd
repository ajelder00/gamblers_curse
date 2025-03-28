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
	#animation for raising up dice
	for j in range(len(current_dice)):
		var new_position = current_dice[j].global_position + Vector2(0, -20)
		var tween_position = get_tree().create_tween()
		tween_position.tween_property(current_dice[j], "global_position", new_position, 0.2).set_trans(Tween.TRANS_SINE)
		var tween_transparency = get_tree().create_tween()
		tween_transparency.tween_property(current_dice[j], "modulate:a", 0, 0.15)
		await get_tree().create_timer(0.1).timeout

	var i = 0
	var amount_popped = 0
	
	while amount_popped < 3:
		if current_dice[i].is_rolled:
			print(i)
			current_dice[i].is_rolled = false
			current_dice.append(current_dice.pop_at(i))
			i -= 1
			amount_popped += 1
			
		i += 1
		
	print('\n')
	
	for die in current_dice:
		print(die.type)
	emit_signal("pop_over")


func reset_positions():
	for j in range(len(current_dice)):
		await get_tree().create_timer(0.1).timeout
		# resets the die's animation to blank
		current_dice[j].animation_player.animation = current_dice[j].ANIMS[current_dice[j].type][0]
		current_dice[j].global_position = positions[j].global_position + Vector2(0, -20)
		if j < 5:
			current_dice[j].get_node("Button").show()
		
		var new_position = positions[j].global_position
		print(new_position)
		var tween_position = get_tree().create_tween()
		tween_position.tween_property(current_dice[j], "global_position", new_position, 0.2).set_trans(Tween.TRANS_SINE)
		
		var tween_transparency = get_tree().create_tween()
		tween_transparency.tween_property(current_dice[j], "modulate:a", 1, 0.2).set_trans(Tween.TRANS_SINE)
