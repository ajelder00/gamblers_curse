extends Node

@export var speed: float = 0.05  # Time delay between letters
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

const MAX_HEALTH: float = 100.0

func _ready() -> void:
	print("battle.gd script is running!")
	_get_ui_elements()
	_initialize_combatants()
	_setup_player()
	_setup_enemy()
	_start_battle()

func _get_ui_elements() -> void:
	roll_message_label = $'Roll Message'  
	player_health_label = $'PlayerHealthNum'
	player_health_bar = $'PlayerHealth'
	
	if not roll_message_label:
		print("ERROR: 'Roll Message' label not found!")
	if not player_health_label:
		print("ERROR: 'PlayerHealthNum' label not found!")
	if not player_health_bar:
		print("ERROR: 'PlayerHealth' bar not found!")

func _initialize_combatants() -> void:
	player = player_template.instantiate()
	enemy = enemy_template.instantiate() # Can change this to a real enemy type based on the battle scene, will handle logic for that later
	add_child(player)
	add_child(enemy)
	
	player_sprite = player.get_node("AnimatedSprite2D")
	enemy_sprite = enemy.get_node("AnimatedSprite2D")
	
	player.attack_signal.connect(_on_player_attack)

func _setup_player() -> void:
	var dice_roller = player.get_node("Dice Roller")
	var player_dice_markers = $DiceBG.get_children()
	dice_roller.set_positions(player_dice_markers)

func _setup_enemy() -> void:
	var enemy_dice = enemy.get_node("Dice") #This will need to change later to accomodate different dice types but also maybe not idk
	var enemy_dice_marker = $EnemyDiceBG/EnemyMarker
	enemy_dice.global_position = enemy_dice_marker.global_position

func _start_battle() -> void:
	if roll_message_label:
		roll_message_label.visible = true
		roll_message_label.text = ""
		_start_typing()
	_update_health_display()

func _on_player_attack() -> void:
	if Global.player_health > 0 and enemy.health > 0:
		_player_turn()
		await get_tree().create_timer(1).timeout
		_enemy_turn()
		await get_tree().create_timer(1).timeout
		print("Full Turn")    
		
		await get_tree().create_timer(0.6).timeout
		player.get_node("Dice Roller").new_hand()
		
		if Global.player_health <= 0: 
			_handle_player_defeat()

func _player_turn() -> void:
	player_sprite.play("attack")
	await player_sprite.animation_finished
	await enemy.get_hit(player.hit())
	print("This is enemy's health: ", enemy.health)
	if enemy.health <= 0:
		_handle_enemy_defeat()

func _enemy_turn() -> void:
	player.get_hit(enemy.hit())
	print("This is Player's health: ", Global.player_health)  
	await enemy_sprite.animation_finished

func _handle_enemy_defeat() -> void:
	enemy_sprite.play("dead")
	print("You have vanquished your enemy.")
	queue_free()

func _handle_player_defeat() -> void:
	player_sprite.play("dead")
	print("Your player has exited this world")

func _start_typing() -> void:
	if message_index >= messages.size():
		return

	var current_text = ""
	var full_text = messages[message_index]
	print("Typing message:", full_text)

	for i in range(full_text.length()):
		current_text += full_text[i]  
		roll_message_label.text = current_text
		await get_tree().create_timer(speed).timeout  

	await get_tree().create_timer(1.0).timeout  
	message_index += 1
	if message_index < messages.size():
		roll_message_label.text = ""
		_start_typing()

func _update_health_display() -> void:
	if player_health_label and player_health_bar:
		var player_health = Global.player_health
		player_health_label.text = str(player_health) + " HP"
		var parent_control = player_health_bar.get_parent() as Control
		if parent_control:
			var max_width = parent_control.get_rect().size.x
			var health_ratio = clamp(player_health / MAX_HEALTH, 0.0, 1.0)
			player_health_bar.set_size(Vector2(max_width * health_ratio, player_health_bar.get_rect().size.y))
