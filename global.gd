extends Node

var money := 0
var dice : Array


func add_dice(new_die: Dice) -> void:
	dice.append(new_die)

func spend(spent) -> void:
	money -= spent
