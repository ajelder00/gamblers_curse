extends Node

@export var speed: float = 0.05  # Time delay between letters

#variables needed for battle logic
@export var player_template: PackedScene
@export var enemy_template: PackedScene

var player
var player_sprite
var enemy
var enemy_sprite


var messages: Array = [
	"> A WILD DUNGEON GOBLIN APPEARED!",
	"> CHOOSE DICE TO ROLL..."
]  
var message_index: int = 0
var roll_message_label: Label
var player_health_label: Label
var player_health_bar: ColorRect
var max_health: float = 100.0  # Adjust based on your game

func _ready() -> void:
	print("battle.gd script is running!")

	# Debug: Print all child nodes
	print("Listing all child nodes of Battle:")
	for child in get_children():
		print(" -", child.name)

	# Get UI elements
	roll_message_label = $'Roll Message'  
	player_health_label = $'PlayerHealthNum'
	player_health_bar = $'PlayerHealth'

	# Check if elements are found
	if roll_message_label == null:
		print("ERROR: 'Roll Message' label not found!")
	if player_health_label == null:
		print("ERROR: 'PlayerHealthNum' label not found!")
	if player_health_bar == null:
		print("ERROR: 'PlayerHealth' bar not found!")

	# Start the message typing effect
	if roll_message_label:
		roll_message_label.visible = true
		roll_message_label.text = ""  # Start empty
		start_typing()

	# Update health display initially
	update_health_display()
	
	# starting initializing player and such
	player_template = preload("res://dummy_player/dummy_player.tscn")
	enemy_template = preload("res://dummy_enemy/dummy_enemy.tscn")
	player = player_template.instantiate()
	enemy = enemy_template.instantiate()
	add_child(player)
	add_child(enemy)
	player.attack_signal.connect(_on_player_attack)
	player_sprite = player.get_node("AnimatedSprite2D")
	player_sprite.animation = "attack"
	enemy_sprite = enemy.get_node("AnimatedSprite2D")
	var dice_roller = player.get_node("Dice Roller")
	
	# Setting player dice positions
	var player_dice_markers = $DiceBG.get_children()
	dice_roller.set_positions(player_dice_markers)
	dice_roller.new_hand()
	
	# Setting enemy dice position
	var enemy_dice = enemy.get_node("Dice")
	var enemy_dice_marker = $EnemyDiceBG/EnemyMarker
	enemy_dice.global_position = enemy_dice_marker.global_position
	
	# hiding old hud elements (can probably delete them in the nodes
	dice_roller.get_node("DiceBox").hide()
	dice_roller.get_node("Label").hide()
	enemy.get_node("Label").hide()
	player.get_node("Label").hide()
	
	

func _on_player_attack():
	if Global.player_health > 0 and enemy.health > 0:
		# ----- Player Turn -----  
		player_sprite.play("attack")
		await player_sprite.animation_finished
		
		# ----- Update Enemy Health 
		await enemy.get_hit(player.hit())
		
		# ----- Enemy Turn 
		if enemy.health <= 0: 
			enemy_sprite.play("dead")
			print("You have vanquished your enemy.")
			return
			
		player.get_hit(enemy.hit()) 
		await enemy_sprite.animation_finished
			
		print("Full Turn")	
		print("This is Player's health: ", Global.player_health)	
		print("This is enemy's health: ", enemy.health)
		
		# code for getting new hand from Dice Roller, this makes it so it shows the dice faces and roll total
		player.get_node("Dice Roller").new_hand()
			
		if Global.player_health <= 0: 
			player_sprite.play("dead")
			print("Your player has exited this world")

func start_typing() -> void:
	if message_index >= messages.size():
		return

	var current_text = ""  
	var full_text = messages[message_index]
	print("Typing message:", full_text)

	for i in range(full_text.length()):
		current_text += full_text[i]  
		roll_message_label.text = current_text
		await get_tree().create_timer(speed).timeout  

	await get_tree().create_timer(1.0).timeout  # Small delay before switching text

	message_index += 1
	if message_index < messages.size():
		roll_message_label.text = ""  # Clear text before starting next message
		start_typing()

func update_health_display() -> void:
	if player_health_label and player_health_bar:
		var player_health = Global.player_health  # Get global health variable
		player_health_label.text = str(player_health) + " HP"

		# Ensure the parent is a Control node to get proper width
		var parent_control = player_health_bar.get_parent() as Control
		if parent_control:
			var max_width = parent_control.get_rect().size.x  # Get full width
			var health_ratio = clamp(player_health / max_health, 0.0, 1.0)

			# Adjust health bar width from right to left
			player_health_bar.set_size(Vector2(max_width * health_ratio, player_health_bar.get_rect().size.y))
