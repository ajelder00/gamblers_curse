extends Node2D

signal turn_over

@onready var ORIGINAL_ROLLS = 3
@onready var current_rolls = ORIGINAL_ROLLS
@onready var dice_bucket = Global.dummy_dice
@onready var dice_bucket_size = dice_bucket.size()
@onready var positions := [$StartPosition1, $StartPosition2, $StartPosition3, $StartPosition4, $StartPosition5]
var current_dice = []
var current_results
var turn_total

func _ready():
	turn_total = 0
	current_results = []
	new_hand()
	
func new_hand():
	current_rolls = ORIGINAL_ROLLS
	turn_total = 0
	for i in range(5):
		# instantiate dice node
		var die = dice_bucket[randi_range(0, len(dice_bucket)-1)].instantiate()
		add_child(die)
		die.global_position = positions[i].global_position
		die.rolled.connect(on_die_rolled)
		current_dice.append(die)
	$Label.text = "Rolls Left: " + str(current_rolls) + " Current Total: " + str(turn_total)

func on_die_rolled(roll_amount: int):
	current_rolls -= 1
	turn_total += roll_amount
	print("Turn total:" + str(turn_total))
	$Label.text = "Rolls Left: " + str(current_rolls) + " Current Total: " + str(turn_total)
	if current_rolls == 0:
		for die in current_dice:
			die.get_node("Button").hide()
		turn_over.emit() 
#
func set_positions(new_positions: Array):
	positions = new_positions
	
