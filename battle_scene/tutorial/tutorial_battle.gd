extends Node

@export var speed: float = 0.05  # Time delay between letters
@export var player_template: PackedScene
@export var enemy_template: PackedScene

var player
var player_sprite
var enemy
var enemy_sprite
var enemy_animation_names
var enemy_starting_health: float  

var messages = [
	"> A WILD DUNGEON GOBLIN\n  APPEARED!",
	"> WELCOME TO YOUR FIRST\n  BATTLE!",
	"> YOU WILL ROLL DICE\n  TO VANQUISH YOUR ENEMIES...",
	"> CLICK ON THREE DICE\n  TO ROLL ON EACH TURN..."
]

var message_index: int = 0
var first_turn_complete: bool = false  
var first_enemy_turn_complete: bool = false  
var tutorial_complete: bool = false  

var roll_message_label: Label
var player_health_label: Label
var enemy_health_label: Label  
var enemy_health_bar: ColorRect  
var arrow: Sprite2D  

const MAX_HEALTH_BAR_WIDTH: float = 308.0

var click_blocker: Control  # Reference to the blocking object

func _ready() -> void:
	_get_ui_elements()
	enemy_health_bar.size.x = MAX_HEALTH_BAR_WIDTH  
	_initialize_combatants()
	_setup_player()
	_setup_enemy()
	_start_battle()
	_update_health_display()
	arrow.visible = false
	
	# Get the click blocker node (must be added in the scene)
	click_blocker = $ClickBlocker  # Assume "ClickBlocker" is the name of the node
	click_blocker.mouse_filter = Control.MOUSE_FILTER_STOP  # Block clicks

func enable_player_clicking() -> void:
	if click_blocker:
		click_blocker.queue_free()  # Removes the blocking object

var health_update_timer: float = 0.0  # Timer to track updates

func _process(delta: float) -> void:
	health_update_timer += delta
	if health_update_timer >= 2.0:  # Every 2 seconds
		_update_health_display()
		health_update_timer = 0.0  # Reset timer

func _get_ui_elements() -> void:
	roll_message_label = $'Roll Message'  
	player_health_label = $'PlayerHealthNum'
	enemy_health_label = $'MonsterHealthNum'
	enemy_health_bar = $'EnemyHealth'  
	arrow = $TutorialGraphics/Arrow  

func _initialize_combatants() -> void:
	player = player_template.instantiate()
	enemy = enemy_template.instantiate()
	add_child(player)
	add_child(enemy)
	
	player_sprite = player.get_node("AnimatedSprite2D")
	enemy_sprite = enemy.get_node("AnimatedSprite2D")
	enemy.position.y -= 130
	player.position.y -= 30
	
	if player.has_signal("attack_signal"):
		player.attack_signal.connect(_on_player_attack)

func _setup_player() -> void:
	var dice_roller = player.get_node("Dice Roller")
	dice_roller.visible = false
	var player_dice_markers = $DiceBG.get_children()
	dice_roller.set_positions(player_dice_markers)
	player_sprite.animation = "attack"

	# Player starts off-screen to the left
	player.global_position.x = -1000
	move_player_in()

func move_player_in() -> void:
	var tween = get_tree().create_tween()
	tween.tween_property(player, "global_position:x", 200, 1.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

func _setup_enemy() -> void:
	var enemy_dice = enemy.dice
	var enemy_dice_marker = $EnemyDiceBG/EnemyMarker
	enemy_dice.global_position = enemy_dice_marker.global_position
	enemy_dice.z_index = 1
	
	if enemy.has_method("hit") and enemy.has_method("get_hit") and enemy.has_meta("health"):
		enemy.health = enemy.get_meta("health")  
		enemy_starting_health = enemy.health  

	if "ANIMS" in enemy and "type" in enemy:
		enemy_animation_names = enemy.ANIMS[enemy.type]

	# Enemy starts off-screen to the right
	enemy.global_position.x = 1000
	move_enemy_in()

func move_enemy_in() -> void:
	var tween = get_tree().create_tween()
	tween.tween_property(enemy, "global_position:x", 912, 1.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

func _start_battle() -> void:
	if roll_message_label:
		roll_message_label.visible = true
		roll_message_label.text = ""
		_start_typing()
	_update_health_display()

func _on_player_attack() -> void:
	if Global.player_health > 0 and enemy and enemy.health > 0:
		_player_turn()
		_update_health_display()
		await get_tree().create_timer(1).timeout

		if not first_turn_complete:
			roll_message_label.text = ""  
			# Move arrow instantly to new position
			arrow.position = Vector2(450, 280)
			arrow.rotation_degrees = 230
			await _start_custom_typing("> GREAT! YOU CAN SEE\n  THE DAMAGE YOU DEALT\n  HERE!")
			first_turn_complete = true  

		await _enemy_turn()  
		await get_tree().create_timer(1).timeout

		# Only show tutorial messages once
		if not tutorial_complete:
			tutorial_complete = true  
			roll_message_label.text = ""
			await _start_custom_typing("> DIFFERENT DICE HAVE\n  DIFFERENT PROPERTIES...")
			await get_tree().create_timer(1).timeout  

			roll_message_label.text = ""
			await _start_custom_typing("> YOU CAN BUY MORE DICE\n  AT THE SHOP AS YOU\n  PROGRESS...")
			await get_tree().create_timer(1).timeout  

			roll_message_label.text = ""
			await _start_custom_typing("> THAT'S ALL YOU NEED\n  TO KNOW. CONTINUE TO FIGHT AND\n  VANQUISH THIS GOBLIN!")
			await get_tree().create_timer(1).timeout  

		player.get_node("Dice Roller").new_hand()
		# After tutorial ends, make sure "ROLL DICE..." appears every turn
		roll_message_label.text = ""
		await _start_custom_typing("> ROLL DICE...")

		await get_tree().create_timer(0.6).timeout

func _player_turn() -> void:
	if not enemy or enemy.health <= 0:
		return

	player_sprite.play("attack")
	enemy_sprite.play(enemy_animation_names[1])  
	await player_sprite.animation_finished
	enemy.get_hit(player.hit())
	_update_health_display()

	if enemy.health <= 0:
		_handle_enemy_defeat()

func _enemy_turn() -> void:
	if Global.player_health <= 0 or not enemy or enemy.health <= 0:
		return

	if not first_enemy_turn_complete:
		roll_message_label.text = ""  
		await _start_custom_typing("> AFTER EACH TURN, THE ENEMY\n  WILL ALSO ATTACK...")
		first_enemy_turn_complete = true  
		arrow.visible = false  
		await get_tree().create_timer(1).timeout

	player.get_hit(enemy.hit())
	_update_health_display()

	# Only show "YOU CAN SEE HOW MUCH DAMAGE..." once in the tutorial
	if not tutorial_complete:
		roll_message_label.text = ""  
		await _start_custom_typing("> YOU CAN SEE HOW MUCH DAMAGE\n  THEY DEALT BY CHECKING YOUR\n  HEALTH BAR...")
		await get_tree().create_timer(1).timeout  

func _handle_enemy_defeat() -> void:
	if enemy:
		# Play the "dead_enemy" animation
		enemy_sprite.play("dead_goblin")
		
		# Disable player from interacting with dice
		player.get_node("Dice Roller").visible = false
		# Show "Vanquished" and gold messages
		roll_message_label.text = ""
		await _start_custom_typing("> CONGRATS! YOU VANQUISHED YOUR ENEMY.")
		await get_tree().create_timer(1).timeout  # Wait for a moment

		roll_message_label.text = ""
		await _start_custom_typing("> YOU EARNED 10 GOLD!")

		# Fade the enemy and move it down during the typewriter effect
		var tween = get_tree().create_tween()
		tween.tween_property(enemy, "modulate", Color(1, 1, 1, 0), 1.0)
		tween.tween_property(enemy, "position", enemy.position + Vector2(0, 50), 1.0)

		# Wait until the tween animation is finished
		await tween.finished
		
		roll_message_label.text = ""
		await _start_custom_typing("> YOU CAN USE GOLD TO BUY DICE AT \n THE SHOP!")
		await get_tree().create_timer(1).timeout  # Wait for a moment

		roll_message_label.text = ""
		await _start_custom_typing("> RETURNING TO MAP...")
		await get_tree().create_timer(1).timeout  # Wait for a moment
		queue_free()



func _handle_player_defeat() -> void:
	player_sprite.play("dead")

func _start_typing() -> void:
	if message_index >= messages.size():
		return

	await _start_custom_typing(messages[message_index])

	# If this is the last message about rolling dice, show Arrow after the delay
	if message_index == messages.size() - 1:
		await get_tree().create_timer(1).timeout
		arrow.visible = true  
		player.get_node("Dice Roller").visible = true
		player.get_node("Dice Roller").new_hand()
		# When tutorial is done, remove the click blocker
		enable_player_clicking()

	await get_tree().create_timer(1).timeout  
	message_index += 1
	if message_index < messages.size():
		roll_message_label.text = ""
		_start_typing()

func _start_custom_typing(text: String) -> void:
	var current_text = ""

	for i in range(text.length()):
		current_text += text[i]  
		roll_message_label.text = current_text
		await get_tree().create_timer(speed).timeout  

	await get_tree().create_timer(1).timeout  

func _update_health_display() -> void:
	if player_health_label:
		player_health_label.text = str(Global.player_health) + " HP"
	if enemy_health_label and enemy:
		enemy_health_label.text = str(enemy.health) + " HP"

	if enemy_health_bar and enemy:
		var health_ratio = enemy.health / 50.0
		var new_size = health_ratio * MAX_HEALTH_BAR_WIDTH
		enemy_health_bar.size.x = new_size
