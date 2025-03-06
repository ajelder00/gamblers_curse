extends Node2D

signal turn_over

@onready var ORIGINAL_ROLLS = 3
@onready var current_rolls = ORIGINAL_ROLLS
@onready var dice_bucket = Global.dummy_dice
@onready var positions := [$StartPosition1, $StartPosition2, $StartPosition3, $StartPosition4, $StartPosition5]
@onready var parent = get_parent()
var current_dice = []
var current_results
var turn_total

func _ready():
	turn_total = 0
	current_results = []
	new_hand()
	
func new_hand():
	if parent is Node2D:
		parent.dice_effects = []
	current_dice = []
	for child in get_children():
		if child is Dice:
			child.queue_free()
	current_rolls = ORIGINAL_ROLLS
	turn_total = 0
	for position in positions:
		# instantiate dice node
		var index = randi_range(0, len(dice_bucket)-1)
		var die = dice_bucket[index].instantiate()
		add_child(die)
		die.global_position = position.global_position
		current_dice.append(die)
		await get_tree().create_timer(0.1).timeout
		die.rolled.connect(on_die_rolled)

func on_die_rolled(roll_amount: int, effect: Array):
	current_rolls -= 1
	turn_total += roll_amount
	if parent is Node2D:
		parent.dice_effects.append(effect)
	
	print("Turn total:" + str(turn_total))
	if current_rolls == 0:
		for die in current_dice:
			die.get_node("Button").hide()
		turn_over.emit() 
#
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
