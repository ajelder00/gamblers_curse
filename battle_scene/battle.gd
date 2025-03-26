extends Node

@export var speed: float = 0.05  # Time delay between letters
@export var player_template: PackedScene
@export var enemy_template: PackedScene

var player
var player_sprite
var enemy
var enemy_sprite
var enemy_starting_health  # Store the enemy's starting health

var messages: Array = [
	"> A WILD DUNGEON GOBLIN APPEARED!",
	"> CHOOSE DICE TO ROLL..."
]  
var message_index: int = 0

var roll_message_label: Label
var player_health_label: Label
var enemy_health_label: Label  
var enemy_health_bar: ColorRect  # This will now be set in _get_ui_elements()

const MAX_HEALTH_BAR_WIDTH: float = 308.0

func _ready() -> void:
	_get_ui_elements()
	enemy_health_bar.size.x = MAX_HEALTH_BAR_WIDTH  # Force initial size
	_initialize_combatants()
	_setup_player()
	_setup_enemy()
	_start_battle()
	update_health_display()

func _process(_delta: float) -> void:
	pass

# ------------------- UI Setup -------------------

func _get_ui_elements() -> void:
	roll_message_label = $'Roll Message'  
	player_health_label = $'PlayerHealthNum'
	enemy_health_label = $'MonsterHealthNum'
	enemy_health_bar = $'EnemyHealth'  # <-- Now correctly fetching "EnemyHealth" (ColorRect)

func _initialize_combatants() -> void:
	player = player_template.instantiate()
	enemy = enemy_template.instantiate()
	add_child(player)
	add_child(enemy)
	
	player_sprite = player.get_node("AnimatedSprite2D")
	enemy_sprite = enemy.get_node("AnimatedSprite2D")
	enemy.position.y -= 130
	player.position.y -= 30
	
	# Connect player's attack signal
	if player.has_signal("attack_signal"):
		player.attack_signal.connect(_on_player_attack)

# ------------------- Player Setup -------------------

func _setup_player() -> void:
	player_sprite.animation = "attack"

# ------------------- Enemy Setup -------------------

func _setup_enemy() -> void:
	var enemy_dice = enemy.get_node("Dice") 
	var enemy_dice_marker = $EnemyDiceBG/EnemyMarker
	enemy_dice.global_position = enemy_dice_marker.global_position
	enemy_dice.z_index = 1
	enemy_starting_health = enemy.health  # Store the actual starting health
	enemy.connect("damage_to_player", _on_enemy_damage)


# ------------------- Battle Flow -------------------

func _start_battle() -> void:
	if roll_message_label:
		roll_message_label.visible = true
		roll_message_label.text = ""
		_start_typing()
	update_health_display()

func _on_player_attack() -> void:
	if Global.player_health > 0 and enemy and enemy.health > 0:
		_player_turn()
		await enemy.damage_over
		print("Enemy Turn Starting")
		_enemy_turn()
		await player.damage_over
		player.get_node("Dice Roller").new_hand()

func _player_turn() -> void:
	if not enemy or enemy.health <= 0:
		return
	await get_tree().create_timer(1).timeout
	player_sprite.play("attack") 
	await player_sprite.animation_finished
	enemy.get_hit(player.hit())

	if enemy.health <= 0:
		_handle_enemy_defeat()

func _enemy_turn() -> void:
	if Global.player_health <= 0 or not enemy or enemy.health <= 0:
		return
	enemy.dice.roll_die(enemy.dice.faces)

func _on_enemy_damage(damage_packet: Damage) -> void:
	await get_tree().create_timer(0.5).timeout
	player.get_hit(damage_packet)

# ------------------- Defeat Handling -------------------

func _handle_enemy_defeat() -> void:
	if enemy:
		enemy_sprite.play("dead")
		Global.coins += enemy.coins
		enemy.queue_free()
		enemy = null  # Prevent further access
		await get_tree().create_timer(1).timeout
		queue_free()

func _handle_player_defeat() -> void:
	player_sprite.play("dead")

# ------------------- Message Typing -------------------

func _start_typing() -> void:
	if message_index >= messages.size():
		return

	var current_text = ""
	var full_text = messages[message_index]

	for i in range(full_text.length()):
		current_text += full_text[i]  
		roll_message_label.text = current_text
		await get_tree().create_timer(speed).timeout  

	await get_tree().create_timer(1.0).timeout  
	message_index += 1
	if message_index < messages.size():
		roll_message_label.text = ""
		_start_typing()

# ------------------- Health Display -------------------

func update_health_display() -> void:

	if player_health_label:
		player_health_label.text = str(Global.player_health) + " HP"
	if enemy_health_label and enemy:
		enemy_health_label.text = str(enemy.health) + " HP"

	# Ensure the health bar size updates properly
	if enemy_health_bar and enemy:
		print("Updating health display")
		var health_ratio = float(enemy.health) / float(enemy_starting_health)
		var new_size = health_ratio * MAX_HEALTH_BAR_WIDTH
		enemy_health_bar.size.x = new_size
