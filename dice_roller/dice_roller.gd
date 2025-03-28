extends Node2D

signal turn_over

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
	
	'''
	for child in get_children():
		if child is Dice:
			child.queue_free()
	'''
	
	for i in len(dice_bucket):
		# instantiate dice node
		# var index = randi_range(0, len(dice_bucket)-1)
		var die = dice_bucket[i].instantiate()
		add_child(die)
		die.global_position = positions[i].global_position
		current_dice.append(die)
		# hide function to prevent player from clicking on last 5 dice
		if i >= 5:
			die.get_node("Button").hide()
		await get_tree().create_timer(0.1).timeout
		die.rolled.connect(_on_die_rolled)

func _on_die_rolled(damage_packet: Damage):
	current_rolls -= 1
	current_results.append(damage_packet)
	
	print("Roll stats: damage:" + str(damage_packet.damage_number) + " type: " + str(damage_packet.type) + " duration: " + str(damage_packet.duration))
	if current_rolls == 0:
		for die in current_dice:
			die.get_node("Button").hide()
		turn_over.emit() 
		

'''
func set_positions(new_positions: Array):
	await get_tree().create_timer(1).timeout
	var starting_dice = get_dice_children()
	positions = new_positions
	for i in range(5):
		starting_dice[i].global_position = positions[i].global_position

func get_dice_children() -> Array:
	var children_of_type = []
	for child in get_children():
		if child is Dice:
			children_of_type.append(child)
	return children_of_type
'''

func new_turn():
	pop_dice()
	reset_positions()
	current_rolls = ORIGINAL_ROLLS
	current_results = []
	
func pop_dice():
	var i = 0
	var amount_popped = 0
	
	while amount_popped < 3:
		if current_dice[i].is_rolled:
			current_dice[i].is_rolled = false
			current_dice.append(current_dice.pop_at(i))
			i -= 1
			amount_popped += 1
			
		i += 1

func reset_positions():
	for j in range(len(current_dice)):
		await get_tree().create_timer(0.1).timeout
		# resets the die's animation to blank
		current_dice[j].animation_player.animation = current_dice[j].ANIMS[current_dice[j].type][0]
		current_dice[j].global_position = positions[j].global_position
		if j < 5:
			current_dice[j].get_node("Button").show()
