extends Node2D

@export var die_template: PackedScene

signal turn_over

@onready var ORIGINAL_ROLLS = 3
@onready var current_rolls = ORIGINAL_ROLLS
var current_dice
var current_results
var turn_total
var prev_total
var positions = []

func _ready():
	turn_total = 0
	current_dice = Global.dice
	current_results = []
	positions = [$StartPosition1, $StartPosition2, $StartPosition3, $StartPosition4, $StartPosition5]
	for start_position in positions:
		var die = die_template.instantiate()
		add_child(die)
		die.position = start_position.position
		die.rolled.connect(on_die_rolled)
		current_dice.append(die)
		current_results.append(die.result)
	
	$Label.text = "Rolls Left: " + str(current_rolls) + " Current Total: " + str(turn_total)
	
	# texture code for eventual positioning of start positions
	var texture_size = $DiceBox.texture.get_size() * $DiceBox.scale
	print(texture_size)
	print(current_results)
	
func new_hand():
	current_rolls = ORIGINAL_ROLLS
	turn_total = 0
	
	for die in current_dice:
		die.queue_free()
	
	current_dice = []
	current_results = []
	for start_position in positions:
		var die = die_template.instantiate()
		add_child(die)
		die.position = start_position.position
		die.rolled.connect(on_die_rolled)
		current_dice.append(die)
		current_results.append(die.result)
		
	$Label.text = "Rolls Left: " + str(current_rolls) + " Current Total: " + str(turn_total)
	


func get_new_roll():
	var index = 0
	for die in current_dice:
		if die.result != current_results[index]:
			turn_total += die.result
			current_results[index] = die.result
			
		index += 1
		

func on_die_rolled():
	current_rolls -= 1
	get_new_roll()
	$Label.text = "Rolls Left: " + str(current_rolls) + " Current Total: " + str(turn_total)
	if current_rolls == 0:
		for die in current_dice:
			die.get_node("Button").hide()
		prev_total = turn_total
		turn_over.emit() 
	
