extends Node

var coins := 0
var dice : Array


func add_dice(new_die: Dice, type: Dice.Type) -> void:
	new_die.type = type
	

func spend(spent) -> void:
	coins -= spent
