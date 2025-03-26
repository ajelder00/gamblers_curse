extends Node2D

signal turn_over

@onready var ORIGINAL_ROLLS = 3
@onready var current_rolls = ORIGINAL_ROLLS
@onready var dice_bucket = Global.dummy_dice
@onready var positions := [$StartPosition1, $StartPosition2, $StartPosition3, $StartPosition4, $StartPosition5]
@onready var parent = get_parent()
var current_dice = []
var current_results := []

func _ready():
	# Grabs the positions from the battle scene
	if self.get_parent().get_parent():
		var battle = self.get_parent().get_parent()
		positions = battle.get_node("DiceBG").get_children()
		positions.reverse()

	self.set_positions(positions)
	new_hand()
	
func new_hand():
	current_dice = []
	current_results = []
	current_rolls = ORIGINAL_ROLLS
	for child in get_children():
		if child is Dice:
			child.queue_free()

	for position in positions:
		# instantiate dice node
		var index = randi_range(0, len(dice_bucket)-1)
		var die = dice_bucket[index].instantiate()
		add_child(die)
		die.global_position = position.global_position
		current_dice.append(die)
		await get_tree().create_timer(0.1).timeout
		die.rolled.connect(_on_die_rolled)

func _on_die_rolled(damage_packet: Damage):
	current_rolls -= 1
	current_results.append(damage_packet)
	
	print("Roll stats: damage:" + str(damage_packet.damage_number) + " type: " + str(damage_packet.type) + " duration: " + str(damage_packet.duration))
	if current_rolls == 0:
		for die in current_dice:
			die.get_node("Button").hide()
		turn_over.emit() 
#
func set_positions(new_positions: Array):
	await get_tree().create_timer(1).timeout
	var starting_dice = get_dice_children()
	positions = new_positions
	for i in range(5):
		starting_dice[i].global_position = positions[i].global_position
	
	
func get_dice_children() -> Array:
	var children_of_type = []
	for child in get_children():
		if child is Dice:
			children_of_type.append(child)
	return children_of_type
