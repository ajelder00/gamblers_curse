extends Node

@export var speed: float = 0.05  # Time delay between letters
@export var player_template: PackedScene
@export var enemy_template: PackedScene

var player
var player_sprite
var enemy
var enemy_sprite
var enemy_animation_names

var messages: Array = [
	"> A WILD DUNGEON GOBLIN APPEARED!",
	"> CHOOSE DICE TO ROLL..."
]  
var message_index: int = 0

var roll_message_label: Label
var player_health_label: Label
var enemy_health_label: Label  

const MAX_HEALTH: float = 100.0

func _ready() -> void:
	_get_ui_elements()
	_initialize_combatants()
	_setup_player()
	_setup_enemy()
	_start_battle()
	_update_health_display()

func _process(delta: float) -> void:
	_update_health_display()

func _get_ui_elements() -> void:
	roll_message_label = $'Roll Message'  
	player_health_label = $'PlayerHealthNum'
	enemy_health_label = $'EnemyHealthNum'

func _initialize_combatants() -> void:
	player = player_template.instantiate()
	enemy = enemy_template.instantiate()
	add_child(player)
	add_child(enemy)
	
	player_sprite = player.get_node("AnimatedSprite2D")
	enemy_sprite = enemy.get_node("AnimatedSprite2D")
	enemy.position.y -= 130
	player.position.y -= 30


	
	player.attack_signal.connect(_on_player_attack)

func _setup_player() -> void:
	var dice_roller = player.get_node("Dice Roller")
	var player_dice_markers = $DiceBG.get_children()
	dice_roller.set_positions(player_dice_markers)
	player_sprite.animation = "attack"

func _setup_enemy() -> void:
	var enemy_dice = enemy.get_node("Dice") 
	var enemy_dice_marker = $EnemyDiceBG/EnemyMarker
	enemy_dice.global_position = enemy_dice_marker.global_position
	enemy_sprite
	
	# setting up animation to be called from battle instead of inside enemy
	enemy_animation_names = enemy.ANIMS[enemy.type]

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

		await get_tree().create_timer(0.6).timeout
		player.get_node("Dice Roller").new_hand()

		_update_health_display()

		if Global.player_health <= 0: 
			_handle_player_defeat()

func _player_turn() -> void:
	player_sprite.play("attack")
	# plays enemy getting damaged animation
	enemy_sprite.play(enemy_animation_names[1])
	await player_sprite.animation_finished
	await enemy.get_hit(player.hit())
	_update_health_display()  # 🔥 Update after attack

	if enemy.health <= 0:
		_handle_enemy_defeat()

func _enemy_turn() -> void:
	player.get_hit(enemy.hit())
	_update_health_display()
	
	
	# enemy_sprite.play("attack")
	# await enemy_sprite.animation_finished

func _handle_enemy_defeat() -> void:
	enemy_sprite.play("dead")
	queue_free()

func _handle_player_defeat() -> void:
	player_sprite.play("dead")

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

func _update_health_display() -> void:
	if player_health_label:
		player_health_label.text = str(Global.player_health) + " HP"
