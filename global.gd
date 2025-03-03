extends Node

var standard = load("res://dice/standard/standard_dice.gd")
var risky = load("res://dice/risky/risky_dice.gd")

var coins := 10
var dummy_dice : Array = [risky, standard]
var dice : Array

## shop inventory to initialize all the dice
var shop_dice = [
	{"type": "standard", "price": 5, "description": "A standard six-sided dice."},
	{"type": "risky", "price": 10, "description": "A risky dice, designed to amplify the stakes."}
				] 

var player_health = 10

func add_dice(new_die: Dice, type: Dice.Type) -> void:
	new_die.type = type
	
func spend(spent) -> void:
	coins -= spent
