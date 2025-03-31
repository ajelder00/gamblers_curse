extends Node2D

const MAX_TURNS := 5
const FIXED_TARGET_SCORE := 19

var player_inventory = Global.dice

@onready var label_coins: Label = $CoinDisplay
@onready var label_messages: Label = $CasinoMessageDisplay
@onready var label_score: Label = $PlayerScore
@onready var label_target: Label = $TargetScore
@onready var label_turns: Label = $TurnDisplay
@onready var payout_button: Button = $PayoutButton
@onready var reset_button: Button = $ResetButton
@onready var exit_button: Button = $ExitButton
@onready var rules_button: Button = $RulesButton
@onready var rules_node: CanvasItem = $RulesNode
@onready var back_button: Button = $RulesNode/Back
@onready var coin_sound: AudioStream = preload("res://music/8bit-coin-sound-effect.mp3")
@onready var coin_sound_player: AudioStreamPlayer = $CoinSound
@onready var player: AnimatedSprite2D = $Player

var sway = true

var messages
var message_index: int = 0
@export var speed: float = 0.03  # Time delay between letters

@onready var inventory_positions = [
	$StartPosition1, $StartPosition2, $StartPosition3,
	$StartPosition4, $StartPosition5, $StartPosition6,
	$StartPosition7, $StartPosition8, $StartPosition9, $StartPosition10
]

@onready var selected_positions = [
	$StartPosition11, $StartPosition12, $StartPosition13,
	$StartPosition14, $StartPosition15
]

var current_turn: int = 1
var player_score: int = 0
var target_score: int = FIXED_TARGET_SCORE

var num_selected: int = 0
var selected_dice: Array = []
var overlay_buttons: Array = []

var rolls_this_turn: int = 0
var rolls_expected: int = 0
var total_coins_earned: int = 0

var is_rolling: bool = false

func _ready() -> void:
	coin_sound_player.stream = coin_sound
	payout_button.disabled = true
	reset_button.disabled = true
	rules_button.pressed.connect(show_rules)
	back_button.pressed.connect(hide_rules)
	rules_node.visible = false
	rules_node.modulate.a = 0.0
	await start_typing("Welcome to Dice Blackjack! Your goal is to get as close to 17 as possible without busting for a payout. May fate be on your side!", true)
	await get_tree().create_timer(1.0).timeout
	reset_button.pressed.connect(reset_hand)
	payout_button.pressed.connect(_on_payout_button_pressed)
	reset_game()
	
func show_rules():
	rules_node.visible = true
	var tween = get_tree().create_tween()
	tween.tween_property(rules_node, "modulate:a", 1.0, 0.5)

func hide_rules():
	var tween = get_tree().create_tween()
	tween.tween_property(rules_node, "modulate:a", 0.0, 0.5)
	tween.tween_callback(func(): rules_node.visible = false)

func reset_game():
	current_turn = 1
	_start_turn()

func _start_turn():
	player_score = 0
	num_selected = 0
	selected_dice.clear()
	rolls_this_turn = 0
	rolls_expected = 0
	is_rolling = false
	target_score = FIXED_TARGET_SCORE

	label_score.text = "Score: 0"
	label_target.text = "Target: %d" % target_score
	label_turns.text = "Turn: %d / %d" % [current_turn, MAX_TURNS]
	label_coins.text = str(Global.coins)

	clear_selected_positions()
	clear_inventory_positions()
	clear_overlay_buttons()
	await start_typing("Start Turn %d. Select 5 dice." % current_turn, false)
	populate_inventory()

	payout_button.disabled = true
	reset_button.disabled = false

func reset_hand():
	if is_rolling:
		await start_typing("You can't reset during rolling!", true)
		return

	player_score = 0
	num_selected = 0
	selected_dice.clear()
	rolls_this_turn = 0
	rolls_expected = 0

	label_score.text = "Score: 0"
	label_coins.text = str(Global.coins)

	clear_selected_positions()
	clear_overlay_buttons()
	populate_inventory()

	await start_typing("Dice selection reset. Select 5 new dice.", true)
	payout_button.disabled = true

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

		var overlay := Button.new()
		overlay.text = ""
		overlay.anchor_left = 0
		overlay.anchor_top = 0
		overlay.anchor_right = 1
		overlay.anchor_bottom = 1
		overlay.offset_left = -20
		overlay.offset_top = -20
		overlay.offset_right = 0
		overlay.offset_bottom = 0
		overlay.mouse_filter = Control.MOUSE_FILTER_STOP
		overlay.focus_mode = Control.FOCUS_NONE
		overlay.flat = true  # Make it visually styled
		overlay.modulate = Color(0, 0, 0, 0)  # Semi-transparent red for visibility
		overlay.custom_minimum_size = Vector2(45, 45)
		overlay.disabled = false

		pos_node.add_child(overlay)
		overlay_buttons.append(overlay)

		var index := i
		overlay.pressed.connect(func():
			overlay.disabled = true
			select_dice_from_inventory(index, pos_node)
		)

func select_dice_from_inventory(index: int, pos_node: Node2D):
	if num_selected >= 5:
		await start_typing("You can only select 5 dice per turn.", true)
		return

	for child in pos_node.get_children():
		if child is Dice:
			child.deactivate()

	var dice_scene = player_inventory[index]
	var new_instance = dice_scene.instantiate()
	var target_pos = selected_positions[num_selected]

	new_instance.scale = Vector2(1, 1)
	new_instance.position = Vector2.ZERO
	target_pos.add_child(new_instance)

	new_instance.rolled.connect(_on_die_rolled)
	selected_dice.append(new_instance)
	num_selected += 1

	await start_typing("Selected %d of 5 dice." % num_selected, true)

	if num_selected == 5:
		payout_button.disabled = false

func roll_dice_one_by_one() -> void:
	reset_button.disabled = true
	exit_button.disabled = true
	await start_typing("Rolling dice...", false)

	rolls_this_turn = 0
	rolls_expected = selected_dice.size()
	is_rolling = true

	for die in selected_dice:
		die.roll_die(die.faces)
		await get_tree().create_timer(2.4).timeout

func _on_die_rolled(damage: Damage) -> void:
	player_score += damage.damage_number
	label_score.text = "Score: %d" % player_score

	if damage.status == Global.Status.POISON:
		var old_target = target_score
		target_score = max(10, target_score - 2)
		label_target.text = "Target: %d" % target_score
		await start_typing("You rolled a %d. Poison! Target reduced from %d to %d." % [damage.damage_number, old_target, target_score], true)
	elif damage.status != Global.Status.NOTHING:
		await start_typing("Rolled with status: %s." % str(damage.status), false)
	else:
		await start_typing("You rolled a %d." % damage.damage_number, false)

	rolls_this_turn += 1

	if rolls_this_turn == rolls_expected:
		call_deferred("calculate_payout")

func _on_payout_button_pressed():
	payout_button.disabled = true
	Global.coins -= 5
	label_coins.text = str(Global.coins)
	floating_text("-" + str(5) + " GOLD", Color.RED, player.global_position)
	await roll_dice_one_by_one()

func calculate_payout():
	await get_tree().create_timer(1.7).timeout
	is_rolling = false
	var payout := 0

	if player_score > target_score:
		await start_typing("You busted with %d. No payout." % player_score, true)
	else:
		var diff = target_score - player_score
		if diff == 0:
			payout = 20
			coin_sound_player.play()
			await start_typing("Jackpot! You earned %d coins." % payout, true)
			floating_text("+" + str(payout) + " GOLD", Color.GOLDENROD, player.global_position)
		elif diff <= 2:
			payout = 10
			coin_sound_player.play()
			await start_typing("Close enough! %d away. You earned %d coins." % [diff, payout], true)
			floating_text("+" + str(payout) + " GOLD", Color.GOLDENROD, player.global_position)		
		else:
			await start_typing("Too far from target. No payout.", true)

	Global.coins += payout
	total_coins_earned += payout
	label_coins.text = str(Global.coins)

	await get_tree().create_timer(2.1).timeout
	exit_button.disabled = false
	advance_to_next_turn()

func advance_to_next_turn():
	if current_turn >= MAX_TURNS:
		end_game()
	else:
		current_turn += 1
		_start_turn()

func end_game():
	await start_typing("Game Over. Total coins earned: %d" % total_coins_earned, true)
	payout_button.disabled = true
	reset_button.disabled = true
	await get_tree().create_timer(3.0).timeout
	queue_free()

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

func _on_exit_button_pressed() -> void:
	print("pressed")
	queue_free()

# message typing
func start_typing(message: String, should_type: bool) -> void:
	label_messages.text = ""
	if should_type:
		Global.typing = true
		for i in range(message.length()):
			label_messages.text += message[i]
			await get_tree().create_timer(speed).timeout
		Global.typing = false
	else:
		label_messages.text = message
		
func floating_text(text: String, color: Color, pos: Vector2) -> void:
	var label = Label.new()
	label.text = text
	label.add_theme_color_override("font_color", color)
	label.add_theme_font_size_override("font_size", 20)
	add_child(label)
	
	label.position = pos + Vector2(
		randf_range(label.position.x +20, label.position.x - 20),
		randf_range(label.position.y -30, label.position.y)
	)
	
	var tween = get_tree().create_tween()
	var target_position = label.position + Vector2(randi_range(-10, 10), -50)
	tween.tween_property(label, "position", target_position, 0.75).set_trans(Tween.TRANS_SINE)
	
	# Fade out
	tween.tween_property(label, "modulate", Color(1, 1, 1, 0), 0.75)
	await tween.finished
	label.queue_free()
