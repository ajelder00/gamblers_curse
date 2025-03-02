extends Node

var standard = load("res://dice/standard/standard_dice.gd")
var risky = load("res://dice/risky/risky_dice.gd")

var coins := 0
var dummy_dice : Array = [risky, standard]
var dice : Array
var player_health = 10

func add_dice(new_die: Dice, type: Dice.Type) -> void:
	new_die.type = type
	
func spend(spent) -> void:
	coins -= spent
