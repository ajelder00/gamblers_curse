extends Node

var standard = load("res://dice/standard/standard_dice.tscn")
var risky = load("res://dice/risky/risky_dice.tscn")

var coins := 10
var dummy_dice: Array = [standard, risky]
var dice : Array

## shop inventory to initialize all the dice
var shop_dice = [
	{"type": "standard", "price": 5, "description": "A standard six-sided dice."},
	{"type": "risky", "price": 10, "description": "A risky dice, designed to amplify the stakes."}
				] 

var player_health = 100

func add_dice(new_die: Dice, type: Dice.Type) -> void:
	new_die.type = type
	
func spend(spent) -> void:
	coins -= spent
