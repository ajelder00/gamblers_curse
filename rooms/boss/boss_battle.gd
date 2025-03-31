extends Node

@onready var map_rect = $Map
@onready var diceopedia_ui = $DiceopediaUI  # New DiceopediaUI reference
@onready var music = $'BattleMusic'
@export var speed: float = 0.05  # Time delay between letters
@export var player_template: PackedScene
@export var override_enemy: bool = true
@onready var enemy_text_ui = $'EnemyTextUI'
@onready var enemy_text = $'EnemyText'
@onready var skip = $'Skip'

@onready var cut_scene = $'CutScene'
var tween
var enemy_speaking = true
var enemy_og_pos
var enemy_template
var ui_elements
var enemy_dice
var player
var player_sprite
var enemy
var enemy_sprite
var enemy_starting_health  # Store the enemy's starting health
var new_music = preload("res://music/6. Veil of Eternal Nightfall (Loop).mp3")
var player_position_og
var sway = false
var messages
var message_index: int = 0
var original_label_position
var roll_message_label: Label
var player_health_label: Label
var enemy_health_label: Label  
var enemy_health_bar: ColorRect  # Set in _get_ui_elements()
var enemy_health_bar2: ColorRect
var enemy_name: Label

const MAX_HEALTH_BAR_WIDTH: float = 266

# Store DiceopediaUI's target position
var diceopedia_target_position: Vector2

func _ready() -> void:
	if not override_enemy:
		enemy_template = pick_enemy(Global.difficulty)
	else:
		enemy_template = Global.king
	_get_ui_elements()
	original_label_position = skip.position
	enemy_health_bar.size.x = MAX_HEALTH_BAR_WIDTH  # Force initial size
	_initialize_combatants()
	_setup_enemy()
	
	# Store DiceopediaUI's target position and move it off screen initially
	diceopedia_target_position = diceopedia_ui.position
	diceopedia_ui.position = diceopedia_target_position + Vector2(0, 300)
	diceopedia_ui.visible = true
	await get_tree().create_timer(1.5).timeout
	var intro_messages = [
		"WHO GOES THERE?",
		"OH . . . ITS YOU. . .",
		"NO MATTER." ,
		"EVEN IF MY DICE CAN'T CONTROL YOU",
		"I WILL STILL END YOUR MISERABLE LIFE",
		"PREPARE TO DIE"
	]  
	for message in intro_messages:
		if enemy_speaking:
			enemy_text_ui.visible = true
			await typewriter_effect(message)
			await get_tree().create_timer(1.5).timeout
			if not music.playing:
				music.playing = true
		if not enemy_speaking:
			enemy_text_ui.visible = false
			$EnemyText.hide()
			enemy_text_ui.visible = false
	if enemy_speaking:
		_start_battle()
	update_health_display()



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
	player_health_label = $'PlayerHealthNum'
	enemy_health_label = $'MonsterHealthNum'
	enemy_health_bar = $'EnemyHealth'  # Fetching the "EnemyHealth" ColorRect
	enemy_health_bar2 = $'EnemyHealth2'
	enemy_name = $'MonsterName'
	var enemy_health_red = $'EnemyHealthBG'
	var enemy_bar = $'EnemyHealthUI'
	var player_bar = $'PlayerHealthUI'
	var player_health = $'PlayerHealth'
	var player_health1 = $'PlayerHealth2'
	var player_health_red = $'PlayerHealthBG'
	var player_name = $'PlayerName'
	var player_platform = $'PlayerPlatform'
	var enemy_platform = $'EnemyPlatform'
	var dice_ui = $'DiceUI'
	ui_elements = [roll_message_label, 
	player_health_label, 
	enemy_health_bar, 
	enemy_health_bar2, 
	enemy_name, 
	enemy_bar, 
	player_bar, 
	player_health, 
	player_health1,
	player_name,
	player_health_red,
	enemy_health_red,
	player_platform,
	enemy_platform,
	dice_ui,
	enemy_health_label
	]
	for ui in ui_elements:
		ui.hide()

func _initialize_combatants() -> void:
	player = player_template.instantiate()
	enemy = enemy_template.instantiate()
	add_child(player)
	add_child(enemy)
	player.roller.hide()
	enemy.dice.hide()
	player_sprite = player.get_node("AnimatedSprite2D")
	enemy_sprite = enemy.get_node("AnimatedSprite2D")
	enemy.position.y -= 130
	player.position.y -= 30
	player_position_og = player.position.x
	player.position.x -= 320
	player_sprite.play("walk")
	tween = get_tree().create_tween()
	tween.tween_property(player, "position:x", player.position.x + 320, 3)
	await get_tree().create_timer(3).timeout
	player_sprite.play("idle")
	await get_tree().create_timer(0.5).timeout
	enemy.sprite.flip_h = true
	# Connect player's attack signal

func _input(event):
	if event.is_action_pressed("skip") and enemy_speaking: 
		enemy.sprite.flip_h = true # Replace with your action
		enemy_text_ui.visible = false
		tween.stop()
		player_sprite.play("idle")
		player.position.x = player_position_og
		enemy_text.visible = false
		enemy_speaking = false
		Global.typing
		_start_battle()


# ------------------- Enemy Setup -------------------

func _setup_enemy() -> void:
	enemy_og_pos = enemy.position
	enemy.position = $KingPos.position
	enemy.sprite.flip_h = false
	enemy_name.text = enemy.NAMES[enemy.type]
	enemy.dice.position.y -= 150
	messages = [
		"> A " + str(enemy_name.text) + " APPEARED!",
		"> CHOOSE THREE DICE TO ROLL..."
	]  
	enemy_starting_health = enemy.health  # Store the starting health
	enemy.connect("damage_to_player", _on_enemy_damage)
	_setup_enemy_dice()

func _setup_enemy_dice() -> void:
	enemy_dice = enemy.dice
	var enemy_dice_marker = $EnemyDiceBG/EnemyMarker
	enemy_dice.global_position = enemy_dice_marker.global_position
	enemy_dice.z_index = 1
	enemy_dice.button.hide()

# ------------------- Battle Flow -------------------
func _process(delta: float) -> void:
	skip.position.y = original_label_position.y + sin(Time.get_ticks_msec() / 1000.0 * 4) * 4

func _start_battle() -> void:
	enemy_text_ui.visible = false
	enemy_text.visible = false
	skip.visible = false
	sway = true
	player.roller.reset_positions()
	if player.has_signal("attack_signal"):
		player.attack_signal.connect(_on_player_attack)
	var cut_scene = $'CutScene'
	cut_scene.visible = true
	player.visible = false
	music.stream = load("res://music/8-bit-gunshot.wav")
	music.play()
	await music.finished
	await get_tree().create_timer(0.75).timeout
	for ui in ui_elements:
		ui.show()
	player.roller.show()
	enemy.dice.show()
	enemy.position = enemy_og_pos
	_setup_enemy_dice()
	music.stream = new_music
	music.stream.loop = true
	music.play()
	await get_tree().create_timer(0.1).timeout
	cut_scene.visible = false
	player.visible = true
	if roll_message_label:
		roll_message_label.visible = true
		roll_message_label.text = ""
		# Slide in the text UI before starting to type messages.
		await slide_in_text_ui()
		_start_typing()
	update_health_display()

func _on_player_attack() -> void:
	if Global.player_health > 0 and enemy and enemy.health > 0:
		_player_turn()
		await enemy.damage_over
		print("Enemy Turn Starting")
		_enemy_turn()

func _player_turn() -> void:
	if not enemy or enemy.health <= 0:
		return
	player_sprite.play("attack") 
	await get_tree().create_timer(0.5).timeout
	player.play_attack_sound()
	await player_sprite.animation_finished
	player_sprite.play("idle")
	enemy.get_hit(player.hit())

func _enemy_turn() -> void:
	if enemy.health <= 0:
		print("Enemy has died!")
		_handle_enemy_defeat()
		return
	if Global.player_health <= 0 or not enemy or enemy.health <= 0:
		return
	for i in range(enemy.turns):
		enemy.set_dice()
		_setup_enemy_dice()
		enemy_dice.roll_die(enemy_dice.faces)
		await player.damage_over
	player.apply_status_self(player.current_effects)
	await player.effects_over
	if (Global.player_health <= 0):
		_handle_player_defeat()
		return
		print("YOU DIED")
	player.get_node("Dice Roller").new_turn()

func _on_enemy_damage(damage_packet: Damage) -> void:
	await get_tree().create_timer(0.5).timeout
	player.get_hit(damage_packet)

# ------------------- Defeat Handling -------------------

func _handle_enemy_defeat() -> void:
	music.stop()
	enemy_sprite.play(enemy.ANIMS[enemy.type][2])
	Global.coins += enemy.coins
	music.stream = load("res://music/8-bit-gunshot.wav")
	music.play()
	await enemy_sprite.animation_finished
	music.stream = load("res://music/frozen_winter.mp3")
	music.play()
	await get_tree().create_timer(1.0).timeout
	var dice = Global.standard.instantiate()
	self.add_child(dice)
	dice.button.hide()
	dice.z_index = 10
	dice.position = enemy.position
	dice.scale = dice.scale*1.5
	dice.animation_player.modulate = Color.GOLDENROD
	dice.animation_player.animation = "roll_cursed"
	dice.animation_player.play()
	tween = get_tree().create_tween()
	
	
	cut_scene = $EndingScene
	cut_scene.color = Color(1.0, 1.0, 0.8)
	var screen_size = get_viewport().get_visible_rect().size
	var position = screen_size / 2  # Center it
	cut_scene.modulate.a = 0
	var tween2 = get_tree().create_tween()
	tween2.tween_property(cut_scene, "modulate:a", 0.95, 5)
	await tween.tween_property(dice, "position", position, 4)
	# Slide in the text UI for the defeat messages.
	await get_tree().create_timer(5.0).timeout
	enemy_speaking = true
	$'EnemyText'.position = position
	enemy_text.position.y += 125
	enemy_text.position.x -= 190
	enemy_text.z_index = 7
	enemy_text.scale *= 2
	enemy_text.text = ""
	enemy_text.visible = true
	Global.audio_player.pitch_scale = 1.2
	var win_messages = ["CONGRATULATIONS! YOU SAVED THE KINGDOM!", "THE PEOPLE ARE FREE FROM THE KING'S CONTROL", "AND THE CURSED DICE IS SAFELY IN YOUR HANDS!"]
	for message in win_messages:
		typewriter_effect(message)
		await get_tree().create_timer(4.5).timeout
	var death_screen = $DeathScreen
	death_screen.visible = true
	death_screen.modulate.a = 0.0
	var tween = create_tween()
	tween.tween_property(death_screen, "modulate:a", 1.0, 3.2)
	tween2 = create_tween()
	tween2.tween_property(dice, "modulate:a", 0, 3.2)
	var tween3 = create_tween()
	tween3.tween_property(enemy_text, "modulate:a", 0, 3.2)
	await tween.finished
	Global.player_health = 100
	Global.audio_player.pitch_scale = 1.2
	get_tree().change_scene_to_file("res://start_menu/start_menu.tscn")


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
	
	# Type out the "ReturnText" text.\
	Global.typing = true
	for i in range(full_return_text.length()):
		return_text_label.text += full_return_text[i]
		await get_tree().create_timer(0.05).timeout
	Global.typing = false
	
	# Wait a moment before returning to the start menu.
	await get_tree().create_timer(2.0).timeout
	Global.reset()
	get_tree().change_scene_to_file("res://start_menu/start_menu.tscn")
# ------------------- Message Typing -------------------

func _start_typing() -> void:
	while message_index < messages.size():
		roll_message_label.text = ""
		var full_text = messages[message_index]
		Global.typing = true
		for i in range(full_text.length()):
			roll_message_label.text += full_text[i]
			await get_tree().create_timer(speed).timeout  
		Global.typing = false
		await get_tree().create_timer(1.0).timeout  
		# When the "CHOOSE THREE DICE TO ROLL..." message (index 1) has been shown, slide out the text UI...
		if message_index == 1:
			await slide_out_text_ui()
			roll_message_label.text = ""
			# ...and then slide DiceopediaUI in.
			await slide_in_diceopedia_ui()
		message_index += 1
	Global.typing = false

# ------------------- Health Display -------------------

func update_health_display() -> void:
	if player_health_label:
		player_health_label.text = str(Global.player_health) + " HP"
	if enemy_health_label and enemy:
		enemy_health_label.text = str(enemy.health) + " HP"

	# Update the health bar size properly.
	if enemy_health_bar and enemy:
		var health_ratio = float(enemy.health) / float(enemy_starting_health)
		var new_size = health_ratio * MAX_HEALTH_BAR_WIDTH
		enemy_health_bar.size.x = new_size
		enemy_health_bar2.size.x = new_size
		
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

func typewriter_effect(message: String):
	if not enemy_speaking:
		Global.typing = false
		return
	Global.typing = true
	for i in message.length():
		if not enemy_speaking:
			Global.typing = false
			return
		$'EnemyText'.text = message.substr(0, i + 1)
		await get_tree().create_timer(0.08).timeout
	Global.typing = false
