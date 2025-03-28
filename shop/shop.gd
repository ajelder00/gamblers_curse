extends Node2D

# Dice Templates 

# Dice Templates (packed scenes)
@export var dice_templates: Dictionary = {
	"standard": preload("res://dice/blinding/blinding_dice.tscn"),
	"risky": preload("res://dice/risky/risky_dice.tscn"),
	"poison": preload("res://dice/poison/poison_dice.tscn"),
	"healing": preload("res://dice/healing/healing_dice.tscn"),
	"blinding": preload("res://dice/blinding/blinding_dice.tscn")
}

# Dice Templates
@export var standard_dice_template: PackedScene
@export var risky_dice_template: PackedScene
@export var poison_dice_template: PackedScene

# Purchase Buttons 
@onready var purchase_risky: Button = $RiskyPurchaseButton
@onready var purchase_standard: Button = $StandardPurchaseButton
@onready var purchase_poison: Button = $PoisonPurchaseButton2

# Dice start positions (6 start positions)
@onready var positions = [
	$StartPosition1, $StartPosition2, $StartPosition3,
	$StartPosition4, $StartPosition5, $StartPosition6
]

# Purchase Button Container
@onready var button_container = $PurchaseButtonContainer

# Dice pricing
var dice_prices = {
	"standard": 5,
	"risky": 10,
	"poison": 20,
	"healing": 15,
	"blinding": 12
}

# Tracks purchased dice types (used to prevent duplicates)
var purchased_instances: Array = []

func _ready():
	populate_shop()

# Dynamically populate shop
func populate_shop():
	var dice_type_list = dice_templates.keys()

	for i in range(positions.size()):
		# Randomly select a dice type for this slot
		var dice_type = dice_type_list[randi() % dice_type_list.size()]
		var dice_scene = dice_templates[dice_type].instantiate()
		dice_scene.global_position = positions[i].global_position
		add_child(dice_scene)

		# Store the actual scene for purchase comparison
		purchased_instances.append({"type": dice_type, "scene": dice_scene})

		# Dynamically create button for this specific dice instance
		var button = Button.new()
		button.text = "Buy %s (%d coins)" % [dice_type.capitalize(), dice_prices[dice_type]]
		button_container.add_child(button)

		# Bind button to purchase this exact dice instance
		var idx := i  # capture current index for closure
		button.pressed.connect(func():
			handle_purchase(idx, button)
		)

# Handle purchase logic
func handle_purchase(index: int, button: Button):
	var entry = purchased_instances[index]
	var dice_type = entry["type"]
	var dice_scene = entry["scene"]
	var price = dice_prices[dice_type]

	if dice_scene in Global.dummy_dice:
		print("You already purchased this dice!")
		return

	if Global.dummy_dice.size() >= 10:
		print("You can't hold more than 10 dice in your inventory!")
		return

	if Global.coins >= price:
		Global.coins -= price
		Global.dummy_dice.append(dice_scene)
		print("Purchased dice: %s" % dice_type)
		button.disabled = true
		button.text = "Purchased"
	else:
		print("Not enough coins to buy: %s!" % dice_type)
