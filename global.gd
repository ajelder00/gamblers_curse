extends Node

var standard := load("res://dice/standard/standard_dice.tscn")
var risky := load("res://dice/risky/risky_dice.tscn")
var poison := load("res://dice/poison/poison_dice.tscn")
var healing := load("res://dice/healing/healing_dice.tscn")
var blinding := load("res://dice/blinding/blinding_dice.tscn")

signal player_healed(heal_amount)

var coins := 10
var dummy_dice: Array = [standard, risky, poison, healing, blinding]
var dice : Array
var can_heal : bool = true

var difficulty: int = 1

enum Status{NOTHING, POISON, BLINDNESS, SHIELD, CURSE, BLEEDING}

const STATUS_PICS := {
	Status.POISON: "res://art/poison_effect.png",
	Status.BLINDNESS: "res://art/blindness_effect.png",
	Status.CURSE: "res://art/curse_effect.png",
	Status.BLEEDING: "res://art/bleeding_effect.png"
}

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

func heal(health) -> void:
	if can_heal:
		Global.player_health = min(Global.player_health + health, 100)
		player_healed.emit(health)
	else:
		Global.player_health = max(Global.player_health - health, 0)
		player_healed.emit(health)
