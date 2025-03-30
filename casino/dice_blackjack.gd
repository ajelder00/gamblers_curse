extends Node2D

const MAX_TURNS := 5
const FIXED_TARGET_SCORE := 20
var sway = true

var player_inventory = Global.dice


@onready var label_coins: Label = $CoinDisplay
@onready var label_messages: Label = $CasinoMessageDisplay
@onready var label_score: Label = $PlayerScore
@onready var label_target: Label = $TargetScore
@onready var label_turns: Label = $TurnDisplay
@onready var payout_button: Button = $PayoutButton
@onready var reset_button: Button = $ResetButton

@onready var inventory_positions = [
	$StartPosition1, $StartPosition2, $StartPosition3,
	$StartPosition4, $StartPosition5, $StartPosition6,
	$StartPosition7, $StartPosition8, $StartPosition9, $StartPosition10
]

@onready var selected_positions = [
	$StartPosition11, $StartPosition12, $StartPosition13,
	$StartPosition14, $StartPosition15
]

var current_turn := 1
var player_score := 0
var target_score := FIXED_TARGET_SCORE

var num_selected := 0
var selected_dice: Array = []
var overlay_buttons: Array = []

var rolls_this_turn := 0
var rolls_expected := 0
var total_coins_earned := 0 


func _ready() -> void:
	label_messages.text = "Welcome to Dice Blackjack! Your goal is to get\nas close to 21 as possible without busting for a payout.\nMay fate be on your side!"
	await get_tree().create_timer(3.5).timeout
	reset_button.pressed.connect(reset_hand)
	payout_button.pressed.connect(_on_payout_button_pressed)
	reset_game()

# ---------------------- Full Game Reset ----------------------

func reset_game():
	current_turn = 1
	_start_turn()

# ---------------------- Reset Just the Hand ----------------------

func reset_hand():
	player_score = 0
	num_selected = 0
	selected_dice.clear()
	rolls_this_turn = 0
	rolls_expected = 0

	label_score.text = "Score: 0"
	label_messages.text = "Dice selection reset. Select 5 new dice."
	label_coins.text = str(Global.coins)

	clear_selected_positions()
	clear_overlay_buttons()
	populate_inventory()

	payout_button.disabled = true

# ---------------------- Start Turn ----------------------

func _start_turn():
	player_score = 0
	num_selected = 0
	selected_dice.clear()
	rolls_this_turn = 0
	rolls_expected = 0
	target_score = FIXED_TARGET_SCORE

	label_score.text = "Score: 0"
	label_target.text = "Target: %d" % target_score
	label_turns.text = "Turn: %d / %d" % [current_turn, MAX_TURNS]
	label_messages.text = "Start Turn %d. Select 5 dice." % current_turn
	label_coins.text = str(Global.coins)

	clear_selected_positions()
	clear_inventory_positions()
	clear_overlay_buttons()
	populate_inventory()

	payout_button.disabled = true

# ---------------------- Populate Inventory ----------------------

func populate_inventory():
	for i in range(min(player_inventory.size(), inventory_positions.size())):
		var dice_scene = player_inventory[i]
		var dice_instance = dice_scene.instantiate()
		var pos_node = inventory_positions[i]

		if "set_as_display_only" in dice_instance:
			dice_instance.set_as_display_only()
		else:
			if dice_instance.has_node("Button"):
				dice_instance.get_node("Button").disabled = true
				dice_instance.get_node("Button").hide()
			if dice_instance.has_node("AnimatedSprite2D"):
				dice_instance.get_node("AnimatedSprite2D").stop()
			if dice_instance.has_node("NameLabel"):
				dice_instance.get_node("NameLabel").visible = false

		dice_instance.scale = Vector2(0.9, 0.9)
		dice_instance.position = Vector2.ZERO
		pos_node.add_child(dice_instance)

		var overlay = Button.new()
		overlay.text = ""
		overlay.anchor_left = 0
		overlay.anchor_top = 0
		overlay.anchor_right = 1
		overlay.anchor_bottom = 1
		overlay.offset_left = 0
		overlay.offset_top = 0
		overlay.offset_right = 0
		overlay.offset_bottom = 0
		overlay.mouse_filter = Control.MOUSE_FILTER_STOP
		overlay.focus_mode = Control.FOCUS_NONE
		overlay.flat = true
		overlay.modulate.a = 0.0
		overlay.custom_minimum_size = Vector2(120, 120)

		pos_node.add_child(overlay)
		overlay_buttons.append(overlay)

		var index := i
		overlay.pressed.connect(func():
			overlay.disabled = true
			select_dice_from_inventory(index, pos_node)
		)

# ---------------------- Select Dice ----------------------

func select_dice_from_inventory(index: int, pos_node: Node2D):
	if num_selected >= 5:
		label_messages.text = "You can only select 5 dice per turn."
		return

	if pos_node.get_child_count() > 0:
		var dice = pos_node.get_child(0)
		dice.modulate = Color(1, 1, 1, 0.35)

	var dice_scene = player_inventory[index]
	var new_instance = dice_scene.instantiate()
	var target_pos = selected_positions[num_selected]

	new_instance.scale = Vector2(1, 1)
	new_instance.position = Vector2.ZERO
	target_pos.add_child(new_instance)

	new_instance.rolled.connect(_on_die_rolled)

	selected_dice.append(new_instance)
	num_selected += 1

	label_messages.text = "Selected %d of 5 dice." % num_selected

	if num_selected == 5:
		await roll_dice_one_by_one()

# ---------------------- Roll Dice One-by-One ----------------------

func roll_dice_one_by_one():
	label_messages.text = "Rolling dice..."
	rolls_this_turn = 0
	rolls_expected = selected_dice.size()

	for die in selected_dice:
		die.roll_die(die.faces)
		await get_tree().create_timer(1.8).timeout

# ---------------------- On Dice Rolled ----------------------

func _on_die_rolled(damage: Damage) -> void:
	player_score += damage.damage_number
	label_score.text = "Score: %d" % player_score

	if damage.status == Global.Status.POISON:
		target_score = max(10, target_score - 2)
		label_target.text = "Target: %d" % target_score
		label_messages.text = "Poison! Target reduced."
	elif damage.status != Global.Status.NOTHING:
		label_messages.text = "Rolled with status: %s." % str(damage.status)
	else:
		label_messages.text = "You rolled a %d." % damage.damage_number

	rolls_this_turn += 1

	if rolls_this_turn == rolls_expected:
		call_deferred("end_turn")

# ---------------------- End Turn ----------------------

func end_turn():
	label_messages.text += " Click payout to collect."
	payout_button.disabled = false

# ---------------------- Manual Payout Handler ----------------------

func _on_payout_button_pressed():
	var payout := 0

	if player_score > target_score:
		label_messages.text = "You busted with %d. No payout." % player_score
	else:
		var diff = target_score - player_score
		if diff <= 2:
			payout = 100
			label_messages.text = "Jackpot! %d away. You earned %d coins." % [diff, payout]
		elif diff <= 5:
			payout = 50
			label_messages.text = "Well done. %d away. You earned %d coins." % [diff, payout]
		elif diff <= 9:
			payout = 20
			label_messages.text = "Close. %d away. You earned %d coins." % [diff, payout]
		else:
			label_messages.text = "Too far from target. No payout."

	Global.coins += payout
	total_coins_earned += payout
	label_coins.text = str(Global.coins)
	payout_button.disabled = true

	await get_tree().create_timer(1.5).timeout
	advance_to_next_turn()

# ---------------------- Advance to Next Turn ----------------------

func advance_to_next_turn():
	if current_turn >= MAX_TURNS:
		end_game()
	else:
		current_turn += 1
		_start_turn()

# ---------------------- End Game ----------------------

func end_game():
	label_messages.text = "Game Over. Total coins earned: %d" % total_coins_earned
	payout_button.disabled = true
	await get_tree().create_timer(3.0).timeout
	queue_free()


# ---------------------- Clearers ----------------------

func clear_selected_positions():
	for pos in selected_positions:
		for child in pos.get_children():
			child.queue_free()

func clear_inventory_positions():
	for pos in inventory_positions:
		for child in pos.get_children():
			child.queue_free()

func clear_overlay_buttons():
	for overlay in overlay_buttons:
		if overlay and overlay.is_inside_tree():
			overlay.queue_free()
	overlay_buttons.clear()
