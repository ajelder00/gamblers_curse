extends Node2D

# Dice Templates
@export var standard_dice_template: PackedScene
@export var risky_dice_template: PackedScene

# Purchase Buttons 
@onready var purchase_risky: Button = $RiskyPurchaseButton
@onready var purchase_standard: Button = $StandardPurchaseButton

# Dice start positions
@onready var positions = [$StartPosition1, $StartPosition2]  

# Load dice scripts from Global
var standard = Global.standard
var risky = Global.risky

func _ready():
	purchase_risky.pressed.connect(_on_risky_purchase_pressed)
	purchase_standard.pressed.connect(_on_standard_purchase_pressed)
	
	var dice_templates = {standard: standard_dice_template, risky: risky_dice_template}

	for dice_script in dice_templates.keys():
		var die_instance = dice_templates[dice_script].instantiate()
		var index = 0 if dice_script == standard else 1  # Assign StartPosition1 or StartPosition2
		die_instance.global_position = positions[index].global_position
		add_child(die_instance)
	
func _on_standard_purchase_pressed():
	handle_purchase(standard, 5)

func _on_risky_purchase_pressed():
	handle_purchase(risky, 10)
	
func handle_purchase(dice_script, price: int):
	
	# Check if player already owns the dice
	if dice_script in Global.dummy_dice:
		print("You already own this dice! No need to purchase again.")
		return

	# Check if player has enough coins
	if Global.coins >= price:
		Global.coins -= price  # Deduct coins
		Global.dummy_dice.append(dice_script)  # Add dice to inventory
		print("Purchased:", dice_script.resource_path)
	else:
		print("Not enough coins!")
	
func _process(delta: float) -> void:
	pass
