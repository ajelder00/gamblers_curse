extends Node2D

@onready var map_rect = $Map
@onready var diceopedia_ui = $DiceopediaUI  # Existing DiceopediaUI reference
@onready var dice_ui = $DiceUI               # New DiceUI reference

@export var speed: float = 0.025  # Time delay between letters
@export var player_template: PackedScene
@export var override_enemy: bool = false

var enemy_template
var sway = true

var enemy_dice
var player
var player_sprite
var enemy
var enemy_sprite
var enemy_starting_health  # Store the enemy's starting health

var enemy_platform: Sprite2D

var messages
var message_index: int = 0

var roll_message_label: Label

# ---------- Enemy UI references (original names) ----------
var enemy_name: Label         # originally MonsterName
var enemy_health_label: Label # originally MonsterHealthNum
var enemy_health_bar: ColorRect  # originally EnemyHealth
var enemy_health_bar2: ColorRect # originally EnemyHealth2
var enemy_health_bg: ColorRect   # originally EnemyHealthBG
var enemy_health_ui: Sprite2D    # originally EnemyHealthUI

# ---------- Player UI references ----------
var player_name: Label         # PlayerName
var player_health_label: Label # PlayerHealthNum
var player_health: ColorRect   # PlayerHealth
var player_health2: ColorRect  # PlayerHealth2
var player_health_bg: ColorRect  # PlayerHealthBG
var player_health_ui: Sprite2D   # PlayerHealthUI

var blocker: ColorRect

const MAX_HEALTH_BAR_WIDTH: float = 266

# Store DiceopediaUI's target position
var diceopedia_target_position: Vector2

# Reference to TutorialCover (ColorRect)
var tutorial_cover: ColorRect

# New flag to track if enemy UI message has been shown
var enemy_ui_message_shown: bool = false

# Flag to track if it is the first enemy turn
var first_enemy_turn: bool = true

func _ready() -> void:
	if not override_enemy:
		enemy_template = pick_enemy(Global.difficulty)
	else:
		enemy_template = Global.wizard
	_get_ui_elements()
	enemy_health_bar.size.x = MAX_HEALTH_BAR_WIDTH  # Force initial size
	_initialize_combatants()
	_setup_enemy()
	
	# Store DiceopediaUI's target position and move it off screen initially
	diceopedia_target_position = diceopedia_ui.position
	diceopedia_ui.position = diceopedia_target_position + Vector2(0, 300)
	diceopedia_ui.visible = true
	
	_start_battle()
	update_health_display()

func _process(_delta: float) -> void:
	pass

func pick_tier(difficulty: int) -> int:
	var tier1_weight = max(0.0, 1.2 - (difficulty * 0.2))  
	var tier3_weight = max(0.0, ((difficulty - 5) * 0.2))  
	var tier2_weight = 1.0 - (tier1_weight + tier3_weight)  

	var roll = randf()
	
	if roll < tier1_weight:
		return 1
	elif roll < tier1_weight + tier2_weight:
		return 2
	else:
		return 3

func pick_enemy(difficulty: int):
	var tier = pick_tier(difficulty)
	return Global.enemies_by_tier[tier].pick_random()

func _get_ui_elements() -> void:
	roll_message_label = $'Roll Message'
	# ---------- Enemy UI references ----------
	enemy_name = $MonsterName
	enemy_health_label = $MonsterHealthNum
	enemy_health_bar = $EnemyHealth
	enemy_health_bar2 = $EnemyHealth2
	enemy_health_bg = $EnemyHealthBG
	enemy_health_ui = $EnemyHealthUI
	enemy_platform = $EnemyPlatform
	# ---------- Player UI references ----------
	player_name = $PlayerName
	player_health_label = $PlayerHealthNum
	player_health = $PlayerHealth
	player_health2 = $PlayerHealth2
	player_health_bg = $PlayerHealthBG
	player_health_ui = $PlayerHealthUI
	# ---------- TutorialCover reference ----------
	tutorial_cover = $TutorialCover
	blocker = $Blocker
	blocker.mouse_filter = Control.MOUSE_FILTER_STOP


func set_player_health_ui_z_indexes() -> void:
	# Set labels to z_index = 8
	player_name.z_index = 8
	player_health_label.z_index = 8
	
	# Set ColorRects z_indexes (PlayerHealth:10, PlayerHealth2:9, PlayerHealthBG:8)
	player_health.z_index = 10
	player_health2.z_index = 9
	player_health_bg.z_index = 8
	
	# Set the Sprite2D for PlayerHealthUI to z_index = 11
	player_health_ui.z_index = 11
	blocker.focus_mode = Control.FOCUS_NONE

func _initialize_combatants() -> void:
	player = player_template.instantiate()
	enemy = enemy_template.instantiate()
	add_child(player)
	add_child(enemy)
	
	player_sprite = player.get_node("AnimatedSprite2D")
	enemy_sprite = enemy.get_node("AnimatedSprite2D")
	enemy.position.y -= 130
	player.position.y -= 30
	
	
	# Set player's z_index to 8
	player.z_index = 8
	player.roller.visible = false
	player.roller.z_index -= 10
	
	# Connect player's attack signal using a Callable.
	if player.has_signal("attack_signal"):
		player.attack_signal.connect(Callable(self, "_on_player_attack"))

func _setup_enemy() -> void:
	enemy_name.text = enemy.NAMES[enemy.type]
	# Set up the messages, all in caps and following the "> ... TEXT ..." format:
	messages = [
		"> WELCOME TO YOUR FIRST BATTLE.",
		"> YOU ARE THE FATED ONE.",
		"> THESE ARE YOUR DICE.",
		"> YOU WILL ROLL UP TO THREE DICE ON EACH TURN.",
		"> THIS IS YOUR ENEMY.",
		"> YOU WILL ROLL YOUR DIE TO VANQUISH THIS " + enemy_name.text.to_upper() + "!",
		"> YOU CAN ONLY ROLL THE FIVE DICE HIGHLIGHTED ON EACH TURN.",
		"> CHOOSE THREE DICE TO ROLL..."
	]
	enemy_starting_health = enemy.health  # Store the starting health
	# Connect enemy's damage signal using a Callable.
	enemy.connect("damage_to_player", Callable(self, "_on_enemy_damage"))
	_setup_enemy_dice()

func _setup_enemy_dice() -> void:
	enemy_dice = enemy.dice
	var enemy_dice_marker = $EnemyDiceBG/EnemyMarker
	enemy_dice.global_position = enemy_dice_marker.global_position
	enemy_dice.z_index = 1
	enemy_dice.button.hide()
func _start_typing() -> void:
	while message_index < messages.size():
		roll_message_label.text = ""
		var full_text = messages[message_index]
		Global.typing = true
		for i in range(full_text.length()):
			roll_message_label.text += full_text[i]
			await get_tree().create_timer(speed).timeout  
		Global.typing = false
		
		# Conditionally show or hide dice buttons based on the current message.
		# When the message is "CHOOSE 3 DICE TO ROLL..." (message_index 7), show the dice buttons.
		if message_index == 7:
			player.get_node("Dice Roller").current_dice[0].button.show()
			player.get_node("Dice Roller").current_dice[1].button.show()
			player.get_node("Dice Roller").current_dice[2].button.show()
			player.get_node("Dice Roller").current_dice[3].button.show()
			player.get_node("Dice Roller").current_dice[4].button.show()
		else:
			player.get_node("Dice Roller").current_dice[0].button.hide()
			player.get_node("Dice Roller").current_dice[1].button.hide()
			player.get_node("Dice Roller").current_dice[2].button.hide()
			player.get_node("Dice Roller").current_dice[3].button.hide()
			player.get_node("Dice Roller").current_dice[4].button.hide()
		
		await get_tree().create_timer(2.0).timeout  
		
		# After showing the second message, change DiceUI's z_index to 8
		if message_index == 1:
			dice_ui.z_index = 8
			player.roller.visible = true
			player.roller.z_index += 10
			
		# After showing the fifth message, change enemy's z_index to 8
		if message_index == 3:
			enemy.z_index = 8
			enemy_platform.z_index = 7
		
		message_index += 1
		Global.typing = false

# ------------------- Battle Flow -------------------

func _start_battle() -> void:
	if roll_message_label:
		roll_message_label.visible = true
		roll_message_label.text = ""
		# Slide in the text UI before starting to type messages.
		await slide_in_text_ui()
		_start_typing()
	update_health_display()

func _on_player_attack() -> void:
	if Global.player_health > 0 and enemy and enemy.health > 0:
		await _player_turn()
		await enemy.damage_over
		print("Enemy Turn Starting")
		await _enemy_turn()

func show_messages(msgs: Array) -> void:
	for msg in msgs:
		roll_message_label.text = ""
		Global.typing = true
		for i in range(msg.length()):
			roll_message_label.text += msg[i]
			await get_tree().create_timer(speed).timeout
		Global.typing = false
		await get_tree().create_timer(0.5).timeout

func _player_turn() -> void:
	if not enemy or enemy.health <= 0:
		return
	player_sprite.play("attack")
	await get_tree().create_timer(0.5).timeout
	player.play_attack_sound()
	await player_sprite.animation_finished
	player_sprite.play("idle")
	
	# Only show enemy UI messages once.
	if not enemy_ui_message_shown:
		
		enemy_name.z_index += 10
		enemy_health_label.z_index += 11
		enemy_health_bar.z_index += 10
		enemy_health_bar2.z_index += 10
		enemy_health_bg.z_index += 10
		enemy_health_ui.z_index += 10
		await show_messages(["> GREAT! THIS IS THE ENEMY HEALTH BAR."])
		await show_messages([
			"> YOUR DAMAGE WILL BE REFLECTED HERE.",
			"> WATCH CLOSELY."
		])
		enemy_ui_message_shown = true
	
	# Then, enemy takes damage.
	enemy.get_hit(player.hit())

func _enemy_turn() -> void:
	if enemy.health <= 0:
		print("Enemy has died!")
		_handle_enemy_defeat()
		return
	if Global.player_health <= 0 or not enemy or enemy.health <= 0:
		return

	# Immediately set first_enemy_turn to false to prevent multiple triggers.
	if first_enemy_turn:
		first_enemy_turn = false
		# Show introductory messages and update player UI.
		await show_messages(["> AFTER YOUR TURN, THE ENEMY WILL ROLL THEIR DICE.", "> EVERY ENEMY HAS A DIFFERENT ATTACK."])
		
		player_name.z_index += 10
		player_health_label.z_index += 10
		player_health.z_index += 10
		player_health2.z_index += 10
		player_health_bg.z_index += 10
		player_health_ui.z_index += 10
		await show_messages(["> THIS IS YOUR HEALTH BAR."])
		await show_messages([
			"> WHATEVER THE ENEMY ROLLS, THE DAMAGE WILL BE REFLECTED HERE.",
			"> WATCH CLOSELY."
		])
		
		# Process enemy attacks.
		for i in range(enemy.turns):
			enemy.set_dice()
			_setup_enemy_dice()
			enemy_dice.roll_die(enemy_dice.faces)
			await player.damage_over
		
		# Show concluding messages and slide out/in UIs.
		await show_messages(["> AFTER YOU USE A DICE, IT WILL BE MOVED TO THE BACK OF YOUR INVENTORY.", "> YOU NOW KNOW EVERYTHING YOU NEED TO KNOW."])
		await show_messages(["> CONTINUE TO ROLL DICE TO VANQUISH YOUR ENEMY!"])
		await slide_out_text_ui()
		roll_message_label.text = ""
		await slide_in_diceopedia_ui()
		var tween_tutorial = create_tween()
		tween_tutorial.tween_property(tutorial_cover, "modulate:a", 0, 1)
		await tween_tutorial.finished
	else:
		# For subsequent enemy turns, process enemy attacks without additional messages.
		for i in range(enemy.turns):
			enemy.set_dice()
			_setup_enemy_dice()
			enemy_dice.roll_die(enemy_dice.faces)
			await player.damage_over

	player.apply_status_self(player.current_effects)
	await player.effects_over
	if Global.player_health <= 0:
		_handle_player_defeat()
		return
	player.get_node("Dice Roller").new_turn()

func _on_enemy_damage(damage_packet: Damage) -> void:
	await get_tree().create_timer(0.5).timeout
	player.get_hit(damage_packet)

# ------------------- Defeat Handling -------------------

func _handle_enemy_defeat() -> void:
	enemy_sprite.play(enemy.ANIMS[enemy.type][2])
	Global.coins += enemy.coins
	await enemy_sprite.animation_finished
	# Slide in the text UI for the defeat messages.
	await slide_in_text_ui()
	# Define defeat messages.
	player.floating_text("+" + str(enemy.coins) + " coins", Color.GOLD)
	$SoundEffect.play()
	var defeat_messages: Array = [
		"> CONGRATS! YOU DEFEATED YOUR FIRST ENEMY.",
		"> YOU EARNED " + str(enemy.coins) + " COINS!",
		"> RETURNING TO MAP..."
	]
	# Type out the defeat messages.
	await _start_defeat_typing(defeat_messages)
	# Fade in the map after messages.
	fade_in_map()

func _start_defeat_typing(defeat_messages: Array) -> void:
	for message in defeat_messages:
		roll_message_label.text = ""
		Global.typing = true
		for i in range(message.length()):
			roll_message_label.text += message[i]
			await get_tree().create_timer(speed).timeout
		Global.typing = false
		await get_tree().create_timer(1.0).timeout

func _handle_player_defeat() -> void:
	player_sprite.play("dead")
	await player_sprite.animation_finished
	
	# Fade in the DeathScreen node.
	var death_screen = $DeathScreen
	death_screen.visible = true
	death_screen.modulate.a = 0.0
	var tween = create_tween()
	tween.tween_property(death_screen, "modulate:a", 1.0, 1.0)
	await tween.finished
	await get_tree().create_timer(0.5).timeout  # Brief pause after fade in.
	
	# Get the labels, store their full text, then clear them for typewriting.
	var you_died_label = death_screen.get_node("YouDied") as Label
	var return_text_label = death_screen.get_node("ReturnText") as Label
	var full_you_died_text = you_died_label.text
	var full_return_text = return_text_label.text
	you_died_label.text = ""
	return_text_label.text = ""
	you_died_label.visible = true
	return_text_label.visible = true
	
	# Type out the "YouDied" text.
	Global.typing = true
	for i in range(full_you_died_text.length()):
		you_died_label.text += full_you_died_text[i]
		await get_tree().create_timer(0.1).timeout
	Global.typing = false
	
	Global.attempts += 1
	await get_tree().create_timer(1.0).timeout  # Pause between texts.
	
	# Type out the "ReturnText" text.
	Global.typing = true
	for i in range(full_return_text.length()):
		return_text_label.text += full_return_text[i]
		await get_tree().create_timer(0.05).timeout
	Global.typing = false
	
	# Wait a moment before returning to the start menu.
	await get_tree().create_timer(2.0).timeout
	Global.player_health = 100
	Global.difficulty = 0
	get_tree().change_scene_to_file("res://start_menu/start_menu.tscn")

# ------------------- Health Display -------------------

func update_health_display() -> void:
	# Update enemy health label text (MonsterHealthNum) and enemy health bar sizes.
	if enemy_health_label and enemy:
		enemy_health_label.text = str(enemy.health) + " HP"
	if enemy_health_bar and enemy:
		var health_ratio_enemy = float(enemy.health) / float(enemy_starting_health)
		var new_size_enemy = health_ratio_enemy * MAX_HEALTH_BAR_WIDTH
		enemy_health_bar.size.x = new_size_enemy
		enemy_health_bar2.size.x = new_size_enemy
	
	# Update player health label text and bar sizes.
	if player_health_label:
		player_health_label.text = str(Global.player_health) + " HP"
	if player_health:
		var health_ratio_player = float(Global.player_health) / 100.0
		var new_size_player = health_ratio_player * MAX_HEALTH_BAR_WIDTH
		player_health.size.x = new_size_player
		player_health2.size.x = new_size_player

func slide_in_text_ui() -> void:
	# Ensure DiceopediaUI is off screen before sliding text in.
	await slide_out_diceopedia_ui()
	
	# TextUI remains at its target y position; Roll Message uses a target y of 535.
	var target_text_y = 390.48
	var target_roll_y = 535.0
	var text_ui = $TextUI
	text_ui.visible = true
	var roll_message = $'Roll Message'
	# Set starting positions 300 pixels below each target.
	text_ui.position = Vector2(text_ui.position.x, target_text_y + 300)
	roll_message.position = Vector2(roll_message.position.x, target_roll_y + 300)
	# Define target positions.
	var target_text_position = Vector2(text_ui.position.x, target_text_y)
	var target_roll_position = Vector2(roll_message.position.x, target_roll_y)
	# Create a tween to slide them into place simultaneously.
	var tween = create_tween()
	tween.parallel().tween_property(text_ui, "position", target_text_position, 1)
	tween.parallel().tween_property(roll_message, "position", target_roll_position, 1)
	await tween.finished

func slide_out_text_ui() -> void:
	var text_ui = $TextUI
	var roll_message = $'Roll Message'
	# TextUI slides out 300 pixels down.
	var target_text_position = text_ui.position + Vector2(0, 300)
	# Roll Message slides to a fixed target y position.
	var target_roll_position = Vector2(roll_message.position.x, 835)
	# Create a tween to slide both out simultaneously.
	var tween = create_tween()
	tween.parallel().tween_property(text_ui, "position", target_text_position, 1)
	tween.parallel().tween_property(roll_message, "position", target_roll_position, 1)
	await tween.finished

# ------------------- DiceopediaUI Sliding -------------------

func slide_in_diceopedia_ui() -> void:
	# Set starting position off screen, then tween into view.
	diceopedia_ui.position = diceopedia_target_position + Vector2(0, 300)
	var tween = create_tween()
	tween.tween_property(diceopedia_ui, "position", diceopedia_target_position, 1)
	await tween.finished

func slide_out_diceopedia_ui() -> void:
	# Tween DiceopediaUI off screen (300 pixels down).
	var tween = create_tween()
	tween.tween_property(diceopedia_ui, "position", diceopedia_target_position + Vector2(0, 300), 1)
	await tween.finished

func fade_in_map():
	map_rect.visible = true
	var map_tween = create_tween()
	map_tween.tween_property(map_rect, "modulate:a", 1.0, 1.5).set_trans(Tween.TRANS_LINEAR)
	await get_tree().create_timer(1.8).timeout 
	queue_free()
