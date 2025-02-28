extends Node2D


@onready var label_coins: Label = $LabelCoins
@onready var bet_amount: SpinBox = $BetAmount
@onready var button_bet: Button = $ButtonBet
@onready var label_result: Label = $LabelResult
@onready var bet_type: OptionButton = $BetType


func _ready() -> void:
	# Update the coins display
	_update_coin_label()
	# Connect the bet button
	button_bet.pressed.connect(_on_button_bet_pressed)
	# Initialize result label
	label_result.text = "Welcome to the Casino! Come Place your bet!"
	
	# Clear any default items
	bet_type.clear()

	# Add bet options to the OptionButton
	bet_type.add_item("Select a Bet")
	bet_type.add_item("Red")
	bet_type.add_item("Black")
	bet_type.add_item("Odd")
	bet_type.add_item("Even")
	for i in range(37):
		bet_type.add_item("Number: %d" % i)

func _on_button_bet_pressed() -> void:
	var bet = int(bet_amount.value)
	
	# Check for sufficient coins
	if bet > Global.coins:
		label_result.text = "Not enough coins!"
		return
	
	# Deduct bet and update coins display
	Global.coins -= bet
	_update_coin_label()
	
	var selected_bet = bet_type.get_item_text(bet_type.selected)
	var win = false
	var multiplier = 0
	
	var outcome_number = randi_range(0, 36)

	
	if selected_bet == "Red":
		# 0 is neither red nor black.
		if outcome_number != 0 and _is_red(outcome_number):
			win = true
			multiplier = 2
	elif selected_bet == "Black":
		if outcome_number != 0 and not _is_red(outcome_number):
			win = true
			multiplier = 2
	elif selected_bet == "Odd":
		if outcome_number != 0 and (outcome_number % 2 == 1):
			win = true
			multiplier = 2
	elif selected_bet == "Even":
		if outcome_number != 0 and (outcome_number % 2 == 0):
			win = true
			multiplier = 2
	elif selected_bet.begins_with("Number"):
		# Option text should be like "Number: 17"
		var parts = selected_bet.split(":")
		if parts.size() == 2:
			var chosen_number = int(parts[1].strip_edges())
			if outcome_number == chosen_number:
				win = true
				multiplier = 35  # Typical roulette payout for a straight number bet
	# Construct result message and update coins accordingly
	var result_msg = "Outcome: %d. " % outcome_number
	if win:
		var winnings = bet * multiplier
		Global.coins += winnings
		result_msg += "You win %d coins!" % winnings
	else:
		result_msg += "You lose."
	
	label_result.text = result_msg
	_update_coin_label()

func _update_coin_label() -> void:
	label_coins.text = "Coins: %d" % Global.coins
	
func _is_red(number: int) -> bool:
	# Hard-coded red numbers for European roulette
	var red_numbers = [1, 3, 5, 7, 9, 12, 14, 16, 18, 19, 21, 23, 25, 27, 30, 32, 34, 36]
	return number in red_numbers
	
	
	
	
