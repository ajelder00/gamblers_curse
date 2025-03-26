extends Node2D

@onready var player_spawn: Marker2D = $PlayerSpawnPoint
@onready var dealer_spawn: Marker2D = $DealerSpawnPoint
@onready var label_coins: Label = $LabelCoins
@onready var bet_amount: SpinBox = $HBoxContainer/BetAmount
@onready var deal_button: Button = $DealButton
@onready var display: Label = $"Display Label"

var card_textures = {}
var typing_speed = 0.005 # seconds between characters


var messages = [
	"Player, welcome to the Casino!\n
	Here we play a simple card game, where you draw from a deck of 13 cards.\n 
	Your card must beat the dealer's in order to win!\n 
	If your card is higher, you win 2 times your bet, otherwise you lose your money!\n
	You have a maximum of 5 turns to win as much money as you can!"
]

var player_card_value = 0
var dealer_card_value = 0
var turns_taken = 0
var max_turns = 5

func _ready():
	randomize()
	load_cards()
	display_messages()
	_update_coin_label()


func display_messages():
	for message in messages:
		await type_text(message)
		await get_tree().create_timer(3.0).timeout  # Pause between messages

func type_text(message: String):
	var current_text = ""
	display.text = current_text
	for character in message:
		current_text += character
		display.text = current_text
		await get_tree().create_timer(typing_speed).timeout

func _update_coin_label() -> void:
	label_coins.text = "You currently have coins: %d" % Global.coins

func load_cards():
	var suits = ["heart"]
	for suit in suits:
		for value in range(1, 14):  # Ace to King
			var path = "res://art/Heart/card_%d_%s.png" % [value, suit]
			var texture = load(path)
			if texture:
				card_textures["%d_%s" % [value, suit]] = texture
			else:
				push_error("Failed to load card: %s" % path)

func display_card(card_value: int, suit: String, spawn_point: Marker2D):
	var key = "%d_%s" % [card_value, suit]
	if key in card_textures:
		var card_sprite = Sprite2D.new()
		card_sprite.texture = card_textures[key]
		card_sprite.position = spawn_point.position
		card_sprite.scale = Vector2(2, 2)
		card_sprite.rotation = deg_to_rad(0)
		add_child(card_sprite)
		animate_card(card_sprite)
	else:
		push_error("Card not loaded: %s" % key)

func animate_card(card_sprite: Sprite2D):
	var tween = create_tween()
	tween.tween_property(card_sprite, "rotation_degrees", 10, 0.1).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(card_sprite, "rotation_degrees", -10, 0.1).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(card_sprite, "rotation_degrees", 0, 0.1).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)


func _on_deal_button_pressed():
	
	if turns_taken >= max_turns:
		print("Maximum number of turns reached!")
		deal_button.disabled = true
		return
	
	var bet = int(bet_amount.value)
	if bet <= 0:
		print("Bet must be greater than zero.")
		return
	if bet > Global.coins:
		print("Not enough coins! Current coins: %d" % Global.coins)
		return

	Global.coins -= bet
	_update_coin_label()

	clear_table()
	player_card_value = randi_range(1, 13)
	dealer_card_value = randi_range(1, 13)

	display_card(player_card_value, "heart", player_spawn)
	await get_tree().create_timer(2.0).timeout

	display_card(dealer_card_value, "heart", dealer_spawn)
	await get_tree().create_timer(0.5).timeout

	check_winner(bet)
	
	turns_taken += 1
	if turns_taken >= max_turns:
		print("Game over! You reached the maximum number of turns.")
		deal_button.disabled = true
	
func check_winner(bet: int):
	var result = ""
	if player_card_value > dealer_card_value:
		result = "Player Wins!"
		Global.coins += bet * 2
	elif dealer_card_value > player_card_value:
		result = "Dealer Wins!"
	else:
		result = "Tie!"
		Global.coins += bet

	_update_coin_label()
	print("Player drew: %d | Dealer drew: %d -> %s" % [player_card_value, dealer_card_value, result])

func clear_table():
	for child in get_children():
		if child is Sprite2D:
			child.queue_free()
			

		
