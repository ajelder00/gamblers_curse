extends Node2D

@export var die_template: PackedScene

var rolls
var current_dice
var current_results
var turn_results
var turn_total

func _ready():
	turn_total = 0
	current_dice = []
	current_results = []
	turn_results = []
	var positions = [$StartPosition1, $StartPosition2, $StartPosition3, $StartPosition4, $StartPosition5]
	for start_position in positions:
		var die = die_template.instantiate()
		add_child(die)
		die.position = start_position.position
		die.rolled.connect(on_die_rolled)
		current_dice.append(die)
		current_results.append(die.result)
	
		
	rolls = 3
	$Label.text = "Rolls Left: " + str(rolls) + " Current Total: " + str(turn_total)
	
	# texture code for eventual positioning of start positions
	var texture_size = $DiceBox.texture.get_size() * $DiceBox.scale
	print(texture_size)
	print(current_results)
	

func get_new_roll():
	var index = 0
	for die in current_dice:
		if die.result != current_results[index]:
			turn_results.append(die.result)
			turn_total += die.result
		

func on_die_rolled():
	rolls -= 1
	get_new_roll()
	$Label.text = "Rolls Left: " + str(rolls) + " Current Total: " + str(turn_total)
	
